@tool
extends Line2D

@export var path : Path2D
@export var num_points : int = 10:
	set(new_value):
		num_points = new_value
		if is_node_ready():
			init_line()

func init_line():
	clear_points()
	for i in range(num_points+1):
		var new_pos := path.curve.sample_baked(path.curve.get_baked_length() - (float(i) / float(num_points) * path.curve.get_baked_length()))
		add_point(new_pos)

func draw_custom_line():
	for i in range(num_points+1):
		var new_pos := path.curve.sample_baked(path.curve.get_baked_length() - (float(i) / float(num_points) * path.curve.get_baked_length()))
		set_point_position(i,new_pos)

func _ready() -> void:
	assert(path)
	init_line()

func _process(_delta: float) -> void:
	draw_custom_line()
