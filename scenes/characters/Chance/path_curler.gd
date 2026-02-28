@tool
extends Path2D

@export var curve_driver_mid_vector : Vector2
@export var curve_driver_end_vector : Vector2

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
@export var curvature : Curve

func _init_curve() -> void:
	curve.clear_points()
	for i in range(path_segments):
		if i == 0:
			curve.add_point(Vector2(0,0))
		else:
			curve.add_point(curve.get_point_position(i-1) + (Vector2(-1,0) * (path_length / path_segments)).rotated(curvature.sample_baked(float(i)/path_segments)))

func _ready() -> void:
	_init_curve()

func _process(delta: float) -> void:
	curvature.set_point_offset(1,curve_driver_mid_vector.x)
	curvature.set_point_value(1,curve_driver_mid_vector.y)
	
	curvature.set_point_offset(2,curve_driver_end_vector.x)
	curvature.set_point_value(2,curve_driver_end_vector.y)
	for i in range(path_segments):
		if i == 0:
			curve.set_point_position(i,Vector2(0,0))
		else:
			curve.set_point_position(i,curve.get_point_position(i-1) + (Vector2(-1,0) * (path_length / path_segments)).rotated(curvature.sample_baked(float(i)/path_segments)))
	
	for i in range(bones_to_drive.size()):
		var bone : Bone2D = bones_to_drive[i]
		var curve_index : int = floor((float(i) / bones_to_drive.size()) * (curve.get_baked_points().size()))
		bone.global_position = curve.get_baked_points()[curve_index]
