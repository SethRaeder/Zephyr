extends CheckButton
class_name HiderButton

var nodes_to_hide = []

func _ready() -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	button_pressed = true
	
	toggled.connect(func(is_on):
		for node in nodes_to_hide:
			print("Set visible: ",is_on)
			node.visible = is_on
	)
