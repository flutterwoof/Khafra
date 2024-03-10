class_name Bank extends Node2D

var Velocities = []
var Programs = []
var Tones = []

func loadMpbFile(fileToLoad):
	# temporary lists
	var ToneDatas = []
	
	if not FileAccess.file_exists(fileToLoad):
		print("Error: File not found")
		return 1
	
	var mpbArray = FileAccess.get_file_as_bytes(fileToLoad)
	var mpbPosition = 0
	
	# does it start with "SMPB" and is that followed by a 2
	if mpbArray.decode_u32(mpbPosition) != 1112558931:
		print("Error: Not an MPB")
		return 1
	mpbPosition += 4 # advance position
	if mpbArray.decode_u32(mpbPosition) != 2:
		print("Error: Wrong MPB format version (must be 2)")
		return 1
	mpbPosition += 4 # advance position
	
	var ptrStart = mpbPosition
	
	var fileSize = mpbArray.decode_u64(mpbPosition)
	mpbPosition += 8
	
	var ptrHeader = mpbPosition
	
	# checking ENDB is in the correct location (at the end of bank)
	mpbPosition = fileSize - 4
	if mpbArray.decode_u32(mpbPosition) != 1111772741:
		print("Error: ENDB is not in the correct place")
		return 1
	mpbPosition += 4
	
	# checking checksum adds up
	mpbPosition = 4
	var calculatedSum = 0
	while mpbPosition < (fileSize - 8):
		calculatedSum += mpbArray.decode_u8(mpbPosition)
		mpbPosition += 1
	if calculatedSum != mpbArray.decode_u32(mpbPosition):
		print("Error: Checksum doesn't match")
		return 1
	mpbPosition += 4
	
	mpbPosition = ptrHeader
	var ptrProgramPointers = mpbArray.decode_u32(mpbPosition)
	mpbPosition += 4
	var numberOfPrograms = mpbArray.decode_u32(mpbPosition)
	mpbPosition += 4
	var ptrVelocities = mpbArray.decode_u32(mpbPosition)
	mpbPosition += 4
	var numberOfVelocities = mpbArray.decode_u32(mpbPosition)
	mpbPosition += 4
	
	# mpbFile.seek(mpbFile.get_position() + 16) # skip unknown data
	
	# get velocities
	mpbPosition = ptrVelocities
	for i in numberOfVelocities:
		var velocity = []
		for x in 128:
			velocity.append(mpbArray.decode_u8(mpbPosition))
			mpbPosition += 1
		Velocities.append(velocity)

	# get program pointers
	var programPointers = []
	mpbPosition = ptrProgramPointers
	for i in numberOfPrograms:
		programPointers.append(mpbArray.decode_u32(mpbPosition))
		mpbPosition += 4


	# Using an index array temporarily to avoid duplicates, as multiple splits
	# might read from the same tone data. I'm defining it here because it's
	# before the program loop, and tone data could be shared across programs.
	var ptrsToneData = []

	# get programs
	for ptrProgram in programPointers:
		#print("Program " + str(programPointers.find(ptrProgram,0)))
		if ptrProgram == 0:
			continue
		var program = Program.new()
		Programs.append(program)
		mpbPosition = ptrProgram
			
		# get layers
		for layerNo in 4:
			#print("	Layer " + str(layerNo))
			var ptrLayer = mpbArray.decode_u32(mpbPosition)
			mpbPosition += 4
			if ptrLayer == 0: # every program has 4 layer pointers, but empty layers point to 0
				continue
				
			mpbPosition = ptrLayer # seek to layer
			
			
			var layer = Layer.new()
			program.Layers.append(layer)
			
			var numberOfSplits = mpbArray.decode_u32(mpbPosition)
			mpbPosition += 4
			var ptrSplits = mpbArray.decode_u32(mpbPosition)
			mpbPosition += 4
			layer.LayerDelay = mpbArray.decode_u16(mpbPosition)
			mpbPosition += 2
			mpbPosition += 2 # skipping an extra word
			layer.BendRangeHigh = mpbArray.decode_u8(mpbPosition)
			mpbPosition += 1
			layer.BendRangeLow = mpbArray.decode_u8(mpbPosition)
			mpbPosition += 1
			mpbPosition += 4
			
			# get splits
			mpbPosition = ptrSplits
			for splitNo in numberOfSplits:
				#print("		Split " + str(splitNo))
				var split = Split.new()
				layer.Splits.append(split)
				
				var toneDataTemp = mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				var toneDataJump = toneDataTemp & 0x0F
				
				var toneDataFlags = mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				if toneDataFlags & 0b00000001: # true = ADPCM, false = Linear
					split.BitDepth = 4
				else:
					if (toneDataTemp >> 4) == 8:
						split.BitDepth = 8
					else:
						split.BitDepth = 16
				if toneDataFlags & 0b00000010:
					split.Loop = true
				else:
					split.Loop = false
				
				var ptrToneData = mpbArray.decode_u16(mpbPosition) + (toneDataJump * 0x10000)
				mpbPosition += 2
				#print("			Tone Data at " + str(ptrToneData))
				split.ToneDataStart = mpbArray.decode_u16(mpbPosition) # loopstart
				mpbPosition += 2
				split.ToneDataEnd = mpbArray.decode_u16(mpbPosition) # numberofsamples
				mpbPosition += 2
				#print("			Tone Data end: " + str(split.ToneDataEnd))
				
				# save pointer to the tone data
				# we'll later replace this with the index in bank
				if ptrToneData != 0:
					split.ToneDataIndex = ptrToneData
				else:
					split.ToneDataIndex = -1
				
				
				# todo: turn this into a class that includes bitdepth
				if !ptrsToneData.has(ptrToneData):
					ptrsToneData.append(ptrToneData)
				
				
				# mask appropriate bits and shift
				
				var ampEnvelopeChunk1 = mpbArray.decode_u16(mpbPosition)
				mpbPosition += 2
				split.AttackRate = ampEnvelopeChunk1 & 0x001F
				split.DecayRate1 = (ampEnvelopeChunk1 & 0x07C0) >> 6
				split.DecayRate2 = (ampEnvelopeChunk1 & 0xF800) >> 11
				
				var ampEnvelopeChunk2 = mpbArray.decode_u16(mpbPosition)
				mpbPosition += 2
				split.DecayLevel = (ampEnvelopeChunk2 & 0x03E0) >> 5
				split.ReleaseRate = (ampEnvelopeChunk2 & 0x001F)
				split.KeyRateScaling = (ampEnvelopeChunk2 & 0x3C00) >> 10
				
				
				mpbPosition += 2
				
				
				var lfoSyncChunk = mpbArray.decode_u16(mpbPosition)
				mpbPosition += 2
				
				split.PitchLfoDepth = (lfoSyncChunk & 0x00E0) >> 5
				split.AmpLfoWave = (lfoSyncChunk & 0x0018) >> 3
				split.AmpLfoDepth = (lfoSyncChunk & 0x0007)
				split.LfoSync = bool((lfoSyncChunk & 0x8000) >> 15)
				split.LfoFrequency = (lfoSyncChunk & 0x7C00) >> 10
				split.PitchLfoWave = (lfoSyncChunk & 0x0300) >> 8
				
				
				var fxChunk = mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				split.FxLevel = (fxChunk & 0xF0) >> 4
				split.FxInputCh = (fxChunk & 0x0F)
				
				
				mpbPosition += 1
				
				var panPot = mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				split.PanDirection = (panPot & 0x30) >> 4
				split.PanQuantity = (panPot & 0x0F)
					
				if split.PanDirection == true:
					split.PanQuantity *= -1
				
				split.DirectLevel = mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				
				
				
				var filterOffAndRes = mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				split.FilterOff = (filterOffAndRes & 0x20) >> 5
				split.FilterResonance = (filterOffAndRes & 0x1F)
				
				split.OscLevel = 255 - mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				split.FilterStartLevel = mpbArray.decode_u16(mpbPosition)
				mpbPosition += 2
				split.FilterAttackLevel = mpbArray.decode_u16(mpbPosition)
				mpbPosition += 2
				split.FilterDecayLevel1 = mpbArray.decode_u16(mpbPosition)
				mpbPosition += 2
				split.FilterDecayLevel2 = mpbArray.decode_u16(mpbPosition)
				mpbPosition += 2
				split.FilterReleaseLevel = mpbArray.decode_u16(mpbPosition)
				mpbPosition += 2
				split.FilterDecayRate1 = mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				split.FilterAttackRate = mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				split.FilterReleaseRate = mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				split.FilterDecayRate2 = mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				
				
				split.NoteRangeLow = mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				split.NoteRangeHigh = mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				split.BaseNote = mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				split.FineTune = mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				
				mpbPosition += 2 # skip FFFF
				
				split.VelocityIndex = mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				split.VelocityLow = mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				split.VelocityHigh = mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				
				split.DrumMode = mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				split.DrumGroupID = mpbArray.decode_u8(mpbPosition)
				mpbPosition += 1
				
				mpbPosition += 1 # skip 00
			
			# seek to program pointer (list of layers) plus however many layers we've done
			mpbPosition = ptrProgram + ((layerNo + 1) * 4)
	
	# sort tone data references
	ptrsToneData.sort()
	
	
	# split out tone data
	var ptrsToneDataLen = len(ptrsToneData)
	for index in len(ptrsToneData):
		var ptrToneData = ptrsToneData[index]
		
		mpbPosition = ptrToneData
		
		var endLocation
		
		if index < ptrsToneDataLen - 1:
			endLocation = ptrsToneData[index + 1] # start of next tone data is end of this data
		else: # okay it's the last one
			endLocation = fileSize - 8 # checksum is end of this data
		
		var ToneData = mpbArray.slice(mpbPosition, mpbPosition + endLocation - ptrsToneData[index])
		ToneDatas.append(ToneData)
	
	
	# check each split and replace tone data in-file reference with bank indices
	for program in Programs:
		for layer in program.Layers:
			for split in layer.Splits:
				if split.ToneDataIndex != -1:
					split.ToneDataIndex = ptrsToneData.find(split.ToneDataIndex)
	
	
	# Todo: don't do this unless user asks
	var tonedatasaveindex = 0
	for toneData in ToneDatas:
		var pcmToneData = Tone.DecodeADPCM(toneData, true)
		var savedPcmToneData = FileAccess.open("C:\\Users\\madr\\Desktop\\decoded" + str(tonedatasaveindex) + ".raw", FileAccess.WRITE)
		tonedatasaveindex += 1
		savedPcmToneData.store_buffer(pcmToneData)
		savedPcmToneData.flush()
		savedPcmToneData.close()
