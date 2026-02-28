@tool
extends Line2D

@export var target_line : Line2D
@export var offset_x_curve : Curve
@export var offset_y_curve : Curve

@export var max_points : int = 50:
	set(new):
		max_points = new
		if is_node_ready():
			init_line()

func init_line():
	clear_points()
	for i in range(min(target_line.points.size(),max_points)):
		var new_pos := target_line.points[i]
		add_point(new_pos)

func _ready() -> void:
	init_line()

func _process(_delta: float) -> void:
	for i in range(points.size()):
		var offset : Vector2 = Vector2(offset_x_curve.sample_baked(i / float(points.size())), offset_y_curve.sample_baked(i/float(points.size())))
		var new_pos : Vector2 = Vector2.ZERO
		if i > 0:
			var normal_vector : Vector2 = (target_line.points[i] - target_line.points[i-1]).rotated(-PI/2.0).normalized()
			new_pos = target_line.points[i] + (offset.rotated(normal_vector.angle()))
		else:
			var normal_vector : Vector2 = (target_line.points[i+1] - target_line.points[i]).rotated(-PI/2.0).normalized()
			new_pos = target_line.points[i] + (offset.rotated(normal_vector.angle()))
		set_point_position(i,new_pos)
