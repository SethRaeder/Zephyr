@tool
extends Line2D

@export var path : Path2D
@export var num_points : int = 10:
	set(new_value):
		num_points = new_value
		init_line()

func init_line():
	clear_points()
	for i in range(num_points+1):
		var new_pos := path.curve.sample_baked(float(i) / float(num_points) * path.curve.get_baked_length())
		add_point(new_pos)
		
func _ready() -> void:
	assert(path)
	init_line()

func _process(_delta: float) -> void:
	for i in range(num_points+1):
		var new_pos := path.curve.sample_baked(float(i) / float(num_points) * path.curve.get_baked_length())
		set_point_position(i,new_pos)
