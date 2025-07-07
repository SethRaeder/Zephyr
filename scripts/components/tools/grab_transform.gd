extends Marker2D
class_name GrabTransform

var grabbed := false
var default_gravity := 1.0
var parent : RigidBody2D

@export var snap_factor_p := 100.0
@export var snap_factor_d := -15.0

@export var grab_area : Area2D

func _ready() -> void:
	add_to_group("grab_transform")
	
	parent = get_parent()
	default_gravity = parent.gravity_scale
	
	if not grab_area:
		parent.connect("input_event",on_input_event)
	else:
		grab_area.connect("input_event",on_input_event)

func _physics_process(_delta: float) -> void:
	if grabbed:
		var vector = Vector2.ZERO
		var part_p = snap_factor_p * (get_global_mouse_position() - global_position)
		var part_d = snap_factor_d * (parent.linear_velocity)
		vector = part_p + part_d
		if position != Vector2.ZERO:
			parent.apply_force(vector, global_position - parent.global_position)
		else:
			parent.apply_central_force(vector)
		#parent.apply_central_force(vector)
		

func on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int):
	if event.is_action_pressed("grab"):
		if ZephyrGlobals.grabbed_tool_ref:
			return
		ZephyrGlobals.grabbed_tool_ref = parent
		parent.gravity_scale = 0.0
		grabbed = true
		if parent.has_method("grab"):
			parent.grab()
		
		ZephyrGlobals.tool_grabbed.emit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("release"):
		if parent.grabbed:
			ZephyrGlobals.grabbed_tool_ref = null
			parent.gravity_scale = default_gravity
			grabbed = false
			if parent.has_method("release"):
				parent.release()
			
			ZephyrGlobals.tool_dropped.emit()
