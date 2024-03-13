class_name Tone extends Node2D

var ADPCMData : PackedByteArray
var PCMData : PackedByteArray
var PCMStream : AudioStreamWAV


# stolen from superctr/adpcm
const stepTable = [230, 230, 230, 230, 307, 409, 512, 614]

# returns 16-bit PCM array
static func DecodeADPCM(adpcmArray: PackedByteArray, highPass: bool) -> Array:
	
	var pcmArray = PackedByteArray()
	var pcmLength = len(adpcmArray) * 4
	pcmArray.resize(pcmLength)
	
	#print("Adpcm Samples: " + str(len(adpcmArray) * 2))
	
	var stepSize = 127
	var history = 0
	var nibble = 4
	
	
	var adpcmArrayIndex = 0
	
	for i in pcmLength:
		if (adpcmArrayIndex >= len(adpcmArray)):
			break
		var step = adpcmArray[adpcmArrayIndex]<<nibble
		step >>= 4
		if !nibble:
			adpcmArrayIndex += 1
		nibble ^= 4
		if highPass:
			history = history * 254 / 256 # high pass
		
		# adpcm step
		var sign = step & 8
		var delta = step & 7
		var diff = ((1+(delta<<1)) * stepSize) >> 3
		var newval = history
		var nstep = (stepTable[delta] * stepSize) >> 8
		
		diff = int(clamp(diff, 0, 32767))
		if (sign > 0):
			newval -= diff
		else:
			newval += diff
		stepSize = clamp(nstep, 127, 24576)
		newval = clamp(newval, -32768, 32767)
		history = newval
		
		pcmArray.encode_s16(i*2, newval)
	
	
	return pcmArray

static func EncodeADPCM(): # todo
	pass
