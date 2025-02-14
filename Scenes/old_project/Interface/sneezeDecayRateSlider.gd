extends HSlider

var editing = false
var max = 1
var min = 500
# Called when the node enters the scene tree for the first time.
func _ready():
	max_value = 1.0
	min_value = 0.0
	
	step = max_value/100
	connect("drag_started", _on_drag_started)
	connect("drag_ended", _on_drag_ended)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not editing:
		value = inverse_lerp(min,max,Globals.SNEEZE['tickleDecayRate'])
	else:
		Globals.SNEEZE['tickleDecayRate'] = lerp(min,max,value)


func _on_drag_started():
	editing = true

func _on_drag_ended(value_changed):
	editing = false
