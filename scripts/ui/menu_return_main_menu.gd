extends Button

func _ready() -> void:
	button_up.connect(GameManager.go_main_menu)
