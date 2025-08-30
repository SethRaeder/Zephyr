extends Node2D

func _ready():
	spawn_character(GameManager.characters[GameManager.current_character_key])

func spawn_character(char_config : CharacterConfig) -> void:
	var char_scene := load(char_config.scene_path)
	assert(char_scene is PackedScene)
	if char_scene is not PackedScene:
		printerr("Loaded character data does not have a valid scene! : ",char_config)
		return
	var new_char : Node2D = load(char_config.scene_path).instantiate()
	new_char.position = char_config.position
	new_char.scale = char_config.scale
	new_char.z_index = char_config.z_index
	
	add_child(new_char)
