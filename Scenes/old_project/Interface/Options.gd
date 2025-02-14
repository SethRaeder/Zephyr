extends Control

@export var buttonGroup:ButtonGroup
var activeButton:Button = null
# Called when the node enters the scene tree for the first time.
func _ready():
	for button in buttonGroup.get_buttons():	
		button.connect("pressed",button_pressed)
		button.get_child(0).hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func button_pressed():
	var newButton = buttonGroup.get_pressed_button()
	if(activeButton == null):
		activeButton = newButton
		activeButton.get_child(0).show()
	
	elif(newButton == activeButton):
		activeButton.get_child(0).hide()
		activeButton.button_pressed = false
		activeButton = null
		
	else: #(activeButton != newButton)
		activeButton.get_child(0).hide()
		activeButton = newButton
		activeButton.get_child(0).show()
	
