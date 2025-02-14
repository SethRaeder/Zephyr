extends HSlider

var editing = false
# Called when the node enters the scene tree for the first time.
func _ready():
	max_value = Globals.FIRE['max']
	step = max_value / 100
	connect("drag_started", _on_drag_started)
	connect("drag_ended", _on_drag_ended)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not editing:
		value = Globals.FIRE['value']
	else:
		Globals.FIRE['value'] = value


func _on_drag_started():
	editing = true

func _on_drag_ended(value_changed):
	editing = false
