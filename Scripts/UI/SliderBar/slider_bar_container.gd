extends GridContainer
class_name SliderBarContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var slider_nodes = get_tree().get_nodes_in_group("has_sliders")
	for node in slider_nodes:
		if node.has_method("send_sliders"):
			node.send_sliders(self)


func add_new_header(text : String):
	var label = Label.new()
	label.text = text
	add_child(label)
	add_child(HSeparator.new())


func add_new_slider(boundedValue : CustomBoundedValue):
	var label = Label.new()
	var slider = SliderBar.new()
	
	label.text = "    " + boundedValue.name
	slider.set_bounded_value(boundedValue)
	
	label.size_flags_horizontal = Control.ANCHOR_BEGIN
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	add_child(label)
	add_child(slider)
