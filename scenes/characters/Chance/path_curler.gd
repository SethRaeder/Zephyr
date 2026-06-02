@tool
class_name PathCurler
extends Path2D

@export var curve_drivers : PackedVector2Array:
	set(new):
		if new.size() != curve_drivers.size():
			curve_drivers = new
			_init_curve()
		else: 
			curve_drivers = new
		_update_curvature()
 
@export var bones_to_drive : Array[Bone2D]

@export var path_length : float = 500:
	set(new):
		path_length = new
		if is_node_ready():
			_init_curve()

@export var path_segments : int = 10:
	set(new):
		path_segments = new
		if is_node_ready():
			_init_curve()

@export var do_IK : bool = false
@export var ik_smoothing : float = 0.2
@export var ik_targets : Array[Marker2D]

var curvature : Curve

func _init_curve() -> void:
	curvature = Curve.new()
	for point in curve_drivers:
		curvature.add_point(point)
	curve.clear_points()
	for i in range(path_segments):
		if i == 0:
			curve.add_point(Vector2(0,0))
		else:
			curve.add_point(curve.get_point_position(i-1) + (Vector2(-1,0) * (path_length / path_segments)).rotated(curvature.sample_baked(float(i)/path_segments)))

func _ready() -> void:
	_init_curve()

func _match_curve() -> void:
	for i in range(path_segments):
		if i == 0:
			curve.set_point_position(i,Vector2(0,0))
		else:
			curve.set_point_position(i,curve.get_point_position(i-1) + (Vector2(-1,0) * (path_length / path_segments)).rotated(curvature.sample_baked(float(i)/path_segments)))

func _update_curvature() -> void:
	#var accumulated_angle : float = 0
	for i in range(curve_drivers.size()):
		#print("Set Point %d %v"%[i,curve_drivers[i]])
		var point = curve_drivers[i] as Vector2
		#accumulated_angle += point.y
		curvature.set_point_offset(i,point.x)
		curvature.set_point_value(i,point.y)

func _process(delta: float) -> void:
	if do_IK:
		ik_solve()
	_update_curvature()
	_match_curve()
	for i in range(bones_to_drive.size()):
		var bone : Bone2D = bones_to_drive[i]
		var curve_index : int = floor((float(i) / bones_to_drive.size()) * (curve.get_baked_points().size()))
		bone.global_position = curve.get_baked_points()[curve_index]

func ik_solve() -> void:
	if ik_targets.is_empty():
		return
	
	for p in range(min(curve_drivers.size(), ik_targets.size())):
		var target_point : Vector2 = ik_targets[p].global_position
		var point_index : int = lerp(0, curve.get_baked_points().size()-1, curve_drivers[p].x / (curve_drivers.size()-1))
		var curve_point : Vector2 = global_position + (curve.get_baked_points()[point_index] * global_scale)
		var angle : float = curve_point.direction_to(target_point).rotated(PI/2).angle() + (PI/2)
		curve_drivers[p].y += ik_smoothing * (angle - curve_drivers[p].y)
		#print("Point %d : %d [%v] angle to target [%v]: %f"%[p,point_index,curve_point, target_point,angle])
		_update_curvature()
		_match_curve()
