extends Control

@onready var mpbTree = get_node("VBoxContainer/HBoxContainer/mpbTree")
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
		cleanMpbTree()
		populateMpbTree()
	elif index == 1: # Open .mpb
		# todo: check if modified / are you sure?
		$LoadFileDialog.popup()
	elif index == 2: # Save .mpb
		$SaveFileDialog.popup()
	elif index == 3: # Exit
		get_tree().quit()

func _on_load_file_dialog_file_selected(path):
	if path != "":
		loadedBank = Bank.new()
		loadedBank.loadMpbFile(path)
		populateMpbTree()
		DisplayServer.window_set_title("Khafra (" + path.get_file() + ")")


func cleanMpbTree():
	pass # todo: cleanup previous stuff

func populateMpbTree():
	# create 'bank' root
	var bankTreeItem = mpbTree.create_item()
	mpbTree.hide_root = true
	
	
	for program in loadedBank.Programs:
		var programTreeItem = mpbTree.create_item(bankTreeItem)
		programTreeItem.set_text(0, "Program " + str(loadedBank.Programs.find(program)))
		for layer in program.Layers:
			var layerTreeItem = mpbTree.create_item(programTreeItem)
			layerTreeItem.set_text(0, "Layer " + str(program.Layers.find(layer)))
			for split in layer.Splits:
				var splitTreeItem = mpbTree.create_item(layerTreeItem)
				splitTreeItem.set_text(0, "Split " + str(layer.Splits.find(split)) + " [" + str(split.NoteRangeLow) + "-" + str(split.NoteRangeHigh) + "]")
