class_name Split extends Node2D

enum Wave {Saw, Square, Triangle, Noise}

var ToneDataIndex : int

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
