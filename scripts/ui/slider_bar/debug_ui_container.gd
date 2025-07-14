extends VBoxContainer
class_name DebugUIContainer

const CURVE_DISPLAY = preload("res://scenes/ui/curve_display/curve_display.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var slider_nodes : Array[Node] = get_tree().get_nodes_in_group("has_sliders")
	var curve_nodes : Array[Node] = get_tree().get_nodes_in_group("has_curves")
	
	for node in slider_nodes:
		if node.has_method("send_sliders"):
			node.send_sliders(self)
	
	for node in curve_nodes:
		if node.has_method("send_curves"):
			pass
			#node.send_curves(self)

var current_hider : HiderButton

func add_new_header(text : String, tooltip : String = ""):
	var label = Label.new()
	var hider = HiderButton.new()
	
	label.text = text
	label.add_theme_color_override("font_color", Color.AQUA)
	
	var hbox : HBoxContainer = HBoxContainer.new()
	hbox.add_child(label)
	hbox.add_child(hider)
	
	hbox.tooltip_text = tooltip
	
	add_child(hbox)
	
	current_hider = hider

func add_new_slider(boundedValue : CustomBoundedValue, tooltip : String = ""):
	var label = Label.new()
	var slider = SliderBar.new()
	
	label.text = "    " + boundedValue.name
	slider.set_bounded_value(boundedValue)
	
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	slider.mouse_filter = Control.MOUSE_FILTER_PASS
	var hbox : HBoxContainer = HBoxContainer.new()
	hbox.add_child(label)
	hbox.add_child(slider)
	hbox.tooltip_text = tooltip
	
	add_child(hbox)
	
	if current_hider:
		current_hider.nodes_to_hide.append(hbox)
		hbox.hide()

func add_new_curve(text : String, curve : Curve):
	var curve_editor = CURVE_DISPLAY.instantiate()
	add_child(curve_editor)
	curve_editor.setup(text,curve)
	
	if current_hider:
		current_hider.nodes_to_hide.append(curve_editor)
		curve_editor.hide()
	
