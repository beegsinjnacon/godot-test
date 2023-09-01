class_name World
extends Node3D

## select map to play on
var map_select: MenuButton
## select character to play
var character_select: MenuButton
## select thing to summon upon pressing the keybind (prob for testing only)
var summon_select: MenuButton

var map
var controller

var error_img = load("res://error.png")

var map_directories = ["res://maps/"];
var character_directories = ["res://characters/","res://fair_use/characters/"];

func _ready():
	map_select = $CanvasLayer/VBoxContainer/map_select
	var maps = [];
	# load map folders
	for directory in map_directories:
		for dir in DirAccess.open(directory).get_directories():
			maps.append(directory+dir+"/");
	# load maps - check each folder for 'map.txt', then load data if exists
	# TODO: error checking malformed files. should just give clearly erroneous output atm
	var index = 0;
	for dir in maps:
		var mapdir = DirAccess.open(dir);
		if mapdir.file_exists("map.txt"):
			var mapdata = FileAccess.open(dir+"map.txt", FileAccess.READ)
			var map_name = "???"
			var map_thumb = error_img;
			var map_path = "???"
			while mapdata.get_position() < mapdata.get_length():
				var line = mapdata.get_line().split("=")
				if not line[0].begins_with("#"):
					match line[0]:
						"name":
							map_name = line[1];
						"thumb":
							# ensure given image is not null
							var test_thumb = load(dir+line[1])
							if test_thumb:
								map_thumb = test_thumb
						"path":
							map_path = dir+line[1];
			map_select.get_popup().add_icon_item(map_thumb, map_name, index)
			map_select.get_popup().set_item_tooltip(index, map_path)
		index += 1;
	
	character_select = $CanvasLayer/VBoxContainer/char_select
	summon_select = $CanvasLayer/VBoxContainer/summon_select
	var characters = [];
	# load character folders
	for directory in character_directories:
		for dir in DirAccess.open(directory).get_directories():
			characters.append(directory+dir+"/");
	# load characters - check each folder for 'character.txt', then load data if exists
	# TODO: error checking malformed files. should just give clearly erroneous output atm
	index = 0;
	for dir in characters:
		var characterdir = DirAccess.open(dir);
		if characterdir.file_exists("character.txt"):
			var characterdata = FileAccess.open(dir+"character.txt", FileAccess.READ)
			var character_name = "???"
			var character_thumb = error_img;
			var character_path = "???"
			while characterdata.get_position() < characterdata.get_length():
				var line = characterdata.get_line().split("=")
				if not line[0].begins_with("#"):
					match line[0]:
						"name":
							character_name = line[1];
						"thumb":
							# ensure given image is not null
							var test_thumb = load(dir+line[1])
							if test_thumb:
								character_thumb = test_thumb
						"path":
							character_path = dir+line[1];
			character_select.get_popup().add_icon_item(character_thumb, character_name, index)
			character_select.get_popup().set_item_tooltip(index, character_path)
			summon_select.get_popup().add_icon_item(character_thumb, character_name, index)
			summon_select.get_popup().set_item_tooltip(index, character_path)
		index += 1;
	map_select.get_popup().index_pressed.connect(func(index): map_select.get_popup().set_focused_item(index))
	character_select.get_popup().index_pressed.connect(func(index): character_select.get_popup().set_focused_item(index))
	summon_select.get_popup().index_pressed.connect(func(index): summon_select.get_popup().set_focused_item(index))
	$CanvasLayer/VBoxContainer/start_button.pressed.connect(game_start)

func game_start():
	$CanvasLayer.hide()
	map = load(map_select.get_popup().get_item_tooltip(map_select.get_popup().get_focused_item()))
	add_child(map.instantiate())
	controller = preload("res://Controller.tscn").instantiate()
	controller.character_scene = load(character_select.get_popup().get_item_tooltip(character_select.get_popup().get_focused_item()))
	controller.summon_scene = load(summon_select.get_popup().get_item_tooltip(summon_select.get_popup().get_focused_item()))
	add_child(controller)
	#await controller.ready
	controller.set_hud_visible(true)

func _unhandled_input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
