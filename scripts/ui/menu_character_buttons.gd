extends VBoxContainer

func _ready() -> void:
	for char in GameManager.characters:
		var new_button : Button = Button.new()
		add_child(new_button)
		new_button.text = char
		new_button.pressed.connect(func():
			GameManager.current_character_key = char
			print("Set current character to ",char)
		)
