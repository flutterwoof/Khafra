extends Control

@onready var bankTree = get_node("MenuSplit/MainSplit/SettingsSplit/TonebankSplit/BankTree") as Tree
@onready var toneTree = get_node("MenuSplit/MainSplit/SettingsSplit/TonebankSplit/ToneTree") as Tree
@onready var settingsTree = get_node("MenuSplit/MainSplit/SettingsSplit/SettingsTree") as Tree
var loadedBank

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_file_index_pressed(index):
	if index == 0: # New .mpb
		# todo: check if modified / are you sure?
		newBank()
	elif index == 1: # Open .mpb
		# todo: check if modified / are you sure?
		$ImportMpbDialog.popup()
	elif index == 2: # Save .mpb
		$ExportMpbDialog.popup()
	elif index == 3: # Exit
		get_tree().quit()

func newBank():
	loadedBank = Bank.new()
	populateMpbTree()
	DisplayServer.window_set_title("Khafra (new bank)")

func importMpbFile(path):
	if path != "":
		loadedBank = Bank.new()
		loadedBank.loadMpbFile(path)
		populateMpbTree()
		DisplayServer.window_set_title("Khafra (" + path.get_file() + ")")
	else:
		print("Error")


func populateMpbTree():
	bankTree.clear()
	toneTree.clear()
	
	# create 'bank' root
	var bankTreeItem = bankTree.create_item()
	bankTree.hide_root = true
	
	for program in loadedBank.Programs:
		var programTreeItem = bankTree.create_item(bankTreeItem)
		programTreeItem.set_text(0, "Program " + str(loadedBank.Programs.find(program)))
		programTreeItem.set_metadata(0, program)
		for layer in program.Layers:
			var layerTreeItem = bankTree.create_item(programTreeItem)
			layerTreeItem.set_text(0, "Layer " + str(program.Layers.find(layer)))
			layerTreeItem.set_metadata(0, layer)
			for split in layer.Splits:
				var splitTreeItem = bankTree.create_item(layerTreeItem)
				splitTreeItem.set_text(0, "Split " + str(layer.Splits.find(split)) + " [" + str(split.NoteRangeLow) + "-" + str(split.NoteRangeHigh) + "]")
				splitTreeItem.set_metadata(0, split)
	
	
	var toneRootTreeItem = toneTree.create_item()
	toneTree.hide_root = true
	
	for tone in loadedBank.Tones:
		var toneTreeItem = toneTree.create_item(toneRootTreeItem)
		toneTreeItem.set_text(0, "Tone " + str(loadedBank.Tones.find(tone)))
		toneTreeItem.set_metadata(0, tone)
		toneTreeItem.add_button(1, Texture2D.new(), -1, false, "Play tone")


func settingsTreeItemEdited():
	print(settingsTree.get_edited())


func bankTreeItemSelected():
	if bankTree.get_selected():
		settingsTree.clear() # remove any leftovers
		var selected = bankTree.get_selected() as TreeItem
		var node = selected.get_metadata(0)
		
		if node is Split:
			node.ShowSettings(settingsTree)



func toneTreeButtonClicked(item: TreeItem, column, id, mouse_button_index):
	if column == 1: # play button column
		var tone: Tone = item.get_metadata(0)
		var streamPlayer: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(streamPlayer)
		streamPlayer.stream = tone.PCMStream
		streamPlayer.play()
		print("Playing")
