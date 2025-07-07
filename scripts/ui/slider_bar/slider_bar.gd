extends HSlider
class_name SliderBar

var bounded_reference : CustomBoundedValue
var dragging : bool = false
func set_bounded_value(bounded_value):
	print("Recieved bounded value: ",bounded_value.to_string())
	bounded_reference = bounded_value
	min_value = bounded_value.min_value
	max_value = bounded_value.max_value
	value = bounded_value.current_value
	step = (max_value - min_value) / 100.0
	
	bounded_reference.changed.connect(_on_reference_changed)
	value_changed.connect(_on_value_changed)
	
	drag_started.connect(_on_drag_started)
	drag_ended.connect(_on_drag_ended)
	
func _on_reference_changed():
	if not dragging:
		set_value_no_signal(bounded_reference.current_value)
	#else:
		#bounded_reference.set_value(value)
	
func _on_value_changed(new_value: float) -> void:
	if dragging:
		bounded_reference.set_value(new_value)

func _on_drag_started() -> void:
	print("Dragging!")
	dragging = true

func _on_drag_ended(value_changed: bool) -> void:
	print("Not Dragging!")
	dragging = false
