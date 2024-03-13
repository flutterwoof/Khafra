class_name Split extends Node2D

enum Wave {Saw, Square, Triangle, Noise}

var ToneDataIndex : int
var Tone : Tone

var BitDepth : int
var Loop : bool
var ToneDataStart : int
var ToneDataEnd : int

var AttackRate : int
var DecayRate1 : int
var DecayRate2 : int
var DecayLevel : int
var ReleaseRate : int
var KeyRateScaling : int

var LfoSync : bool
var LfoFrequency : int
var PitchLfoDepth : int
var PitchLfoWave : Wave
var AmpLfoDepth : int
var AmpLfoWave : Wave

var FxLevel : int
var FxInputCh : int

var PanDirection : bool
var PanQuantity : int

var DirectLevel : int

var FilterOff : bool
var FilterResonance : int
var OscLevel : int
var FilterStartLevel : int
var FilterAttackLevel : int
var FilterDecayLevel1 : int
var FilterDecayLevel2 : int
var FilterReleaseLevel : int
var FilterDecayRate1 : int
var FilterAttackRate : int
var FilterReleaseRate : int
var FilterDecayRate2 : int

var NoteRangeLow : int
var NoteRangeHigh : int
var BaseNote : int
var FineTune : int

var VelocityIndex : int
var VelocityLow : int
var VelocityHigh : int

var DrumMode : int
var DrumGroupID : int


# tone playback
var PCMStream : AudioStreamWAV

func SetupPCM():
	PCMStream.format = AudioStreamWAV.FORMAT_16_BITS
	



# generating settings Tree
func ShowSettings(settingsTree: Tree):
	var root = settingsTree.create_item()
	settingsTree.hide_root = true
	
	
	var noteCategoryTreeItem = settingsTree.create_item(root)
	noteCategoryTreeItem.set_text(0, "Note")
	
	var startNoteTreeItem = settingsTree.create_item(noteCategoryTreeItem)
	startNoteTreeItem.set_text(0, "Start Note")
	startNoteTreeItem.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	startNoteTreeItem.set_range_config(1, 0, 127, 1, false)
	startNoteTreeItem.set_range(1, NoteRangeLow)
	startNoteTreeItem.set_editable(1, true)
	
	var endNoteTreeItem = settingsTree.create_item(noteCategoryTreeItem)
	endNoteTreeItem.set_text(0, "End Note")
	endNoteTreeItem.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	endNoteTreeItem.set_range_config(1, 0, 127, 1, false)
	endNoteTreeItem.set_range(1, NoteRangeHigh)
	endNoteTreeItem.set_editable(1, true)
	
	
	var velocityCategoryTreeItem = settingsTree.create_item(root)
	velocityCategoryTreeItem.set_text(0, "Velocity")
	
	var velocityCurveTreeItem = settingsTree.create_item(velocityCategoryTreeItem)
	velocityCurveTreeItem.set_text(0, "Velocity Curve Index")
	velocityCurveTreeItem.set_text(1, str(VelocityIndex))
	velocityCurveTreeItem.set_editable(1, true)
	
	var velocityLowTreeItem = settingsTree.create_item(velocityCategoryTreeItem)
	velocityLowTreeItem.set_text(0, "Velocity Low")
	velocityLowTreeItem.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	velocityLowTreeItem.set_range_config(1, 0, 127, 1, false)
	velocityLowTreeItem.set_range(1, VelocityLow)
	velocityLowTreeItem.set_editable(1, true)
	
	var velocityHighTreeItem = settingsTree.create_item(velocityCategoryTreeItem)
	velocityHighTreeItem.set_text(0, "Velocity High")
	velocityHighTreeItem.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	velocityHighTreeItem.set_range_config(1, 0, 127, 1, false)
	velocityHighTreeItem.set_range(1, VelocityHigh)
	velocityHighTreeItem.set_editable(1, true)
	
	
	var toneCategoryTreeItem = settingsTree.create_item(root)
	toneCategoryTreeItem.set_text(0, "Tone")
	
	var toneDataIndexTreeItem = settingsTree.create_item(toneCategoryTreeItem)
	toneDataIndexTreeItem.set_text(0, "Tone Data Index")
	toneDataIndexTreeItem.set_text(1, str(ToneDataIndex))
	toneDataIndexTreeItem.set_editable(1, true)
	
	var loopSelectTreeItem = settingsTree.create_item(toneCategoryTreeItem)
	loopSelectTreeItem.set_text(0, "Loop")
	loopSelectTreeItem.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
	loopSelectTreeItem.set_checked(1, Loop)
	loopSelectTreeItem.set_editable(1, true)
	
	var baseNoteTreeItem = settingsTree.create_item(toneCategoryTreeItem)
	baseNoteTreeItem.set_text(0, "Base Note")
	baseNoteTreeItem.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	baseNoteTreeItem.set_range_config(1, 0, 127, 1, false)
	baseNoteTreeItem.set_range(1, BaseNote)
	baseNoteTreeItem.set_editable(1, true)
	
	var fineTuneTreeItem = settingsTree.create_item(toneCategoryTreeItem)
	fineTuneTreeItem.set_text(0, "Fine Tune")
	fineTuneTreeItem.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	fineTuneTreeItem.set_range_config(1, -64, 63, 1, false)
	fineTuneTreeItem.set_range(1, FineTune)
	fineTuneTreeItem.set_editable(1, true)
	
	
	# todo, all the other properties
	
	var filterCategoryTreeItem = settingsTree.create_item(root)
	filterCategoryTreeItem.set_text(0, "Filter")
	
	var filterEnabledTreeItem = settingsTree.create_item(filterCategoryTreeItem)
	filterEnabledTreeItem.set_text(0, "Enabled")
	filterEnabledTreeItem.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
	filterEnabledTreeItem.set_checked(1, !FilterOff)
	filterEnabledTreeItem.set_editable(1, true)
	
	var filterAttackLevelTreeItem = settingsTree.create_item(filterCategoryTreeItem)
	filterAttackLevelTreeItem.set_text(0, "Attack Level")
	filterAttackLevelTreeItem.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	filterAttackLevelTreeItem.set_range_config(1, 0, 8184, 4, false)
	filterAttackLevelTreeItem.set_range(1, FilterAttackLevel * 4)
	filterAttackLevelTreeItem.set_editable(1, true)
	
	
	# https://old.reddit.com/r/godot/comments/monb7z/optionbutton_in_treenode_problem/
	# reddit post because there's no fucking documentation
