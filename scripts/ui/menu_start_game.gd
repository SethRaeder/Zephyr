extends Button



func _ready() -> void:
	pressed.connect(func():
		GameManager.start_game()
	)
