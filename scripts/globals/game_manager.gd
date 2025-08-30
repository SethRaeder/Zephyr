extends Node

##Holds refs to global state stuff, like which character is selected.

var characters : Dictionary[String,CharacterConfig] = {
	"Kel" : preload("res://resources/character_config/kel_config.tres"),
	"Zephyr" : preload("res://resources/character_config/zephyr_config.tres"),
}

var current_character_key : String = ""

var levels : Dictionary[String,Resource] = {
	"Cave" : preload("res://scenes/levels/cave_level.tscn")
}

var current_level_key : String = "Cave"

var main_menu : String = "res://scenes/ui/main_menu.tscn"

func go_main_menu():
	get_tree().change_scene_to_file(main_menu)

func start_game():
	if GameManager.current_character_key.is_empty():
		return
	if not GameManager.characters.has(GameManager.current_character_key):
		return
	if not GameManager.levels.has(GameManager.current_level_key):
		return
		
	get_tree().change_scene_to_file(GameManager.levels[GameManager.current_level_key].resource_path)
