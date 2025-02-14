extends CheckButton


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	button_pressed = Globals.tool_locked
	
func _on_pressed():
	Globals.tool_locked = !Globals.tool_locked
