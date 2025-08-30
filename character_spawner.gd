extends Node2D

@export var characters : Dictionary[String,CharacterConfig]
@export var current_character : String = "Kel"

func _ready():
	assert(characters.has(current_character))

	var char_data : CharacterConfig = characters[current_character]
	assert(char_data)
	if not char_data:
		printerr("Char data not valid or missing!")
		return
		
	var char_scene := load(char_data.scene_path)
	assert(char_scene is PackedScene)
	if char_scene is not PackedScene:
		printerr("Loaded character data does not have a valid scene! : ",char_data)
		return
	var new_char : Node2D = load(char_data.scene_path).instantiate()
	new_char.position = char_data.position
	new_char.scale = char_data.scale
	new_char.z_index = char_data.z_index
	
	add_child(new_char)
