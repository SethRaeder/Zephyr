extends Node2D

var character_dict : Dictionary = {
	"kel" : {
		"scene":"res://scenes/characters/Kel/kel_rig.tscn",
		"position":Vector2(1034,640),
		"scale":Vector2(0.7,0.7),
		"z_index":-10,
	},
	"zephyr" : {
		"scene":"res://scenes/characters/Zephyr/zephyr_rig.tscn",
		"position":Vector2(1046,522),
		"scale":Vector2(0.25,0.25),
		"z_index":-10,
	}
}

var current_character : String = "kel"

func _ready():
	assert(character_dict.has(current_character))

	var char_data : Dictionary = character_dict[current_character]
	assert(char_data.has("scene"))
	assert(char_data.has("position"))
	assert(char_data.has("scale"))
	assert(char_data.has("z_index"))
	
	if not char_data.is_empty():
		var char_scene := load(char_data.scene)
		assert(char_scene is PackedScene)
		if char_scene is not PackedScene:
			printerr("Loaded character data does not have a valid scene! : ",char_data)
			return
		var new_char : Node2D = load(char_data.scene).instantiate()
		new_char.position = char_data.position
		new_char.scale = char_data.scale
		new_char.z_index = char_data.z_index
		
		add_child(new_char)
