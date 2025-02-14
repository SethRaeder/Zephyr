extends Sprite2D

@onready var feather_root: Node2D = $FeatherRoot
@export var spawn_graph: Curve
@export var spawn_scale_graph: Curve
@export var min_angle = -1.0
@export var max_angle = 1.0
@export var numfeathers = 60.0;
@export var min_scale = 0.5;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var last_feather = feather_root
	var start_scale = last_feather.scale
	var end_scale = start_scale * min_scale
	
	for i in range(numfeathers):
		var new_feather: Node2D = last_feather.duplicate()
		add_child(new_feather)
		new_feather.scale = lerp(start_scale, end_scale,spawn_scale_graph.sample(i/numfeathers))
		new_feather.rotation = randf_range(min_angle * spawn_graph.sample(i/numfeathers),max_angle * spawn_graph.sample(i/numfeathers));
		var colorMod = randf_range(.7,1.5)
		new_feather.modulate = Color(colorMod, colorMod, colorMod)
		last_feather = new_feather
