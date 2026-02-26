@tool
extends Polygon2D

@export var line_a : Line2D
@export var line_b : Line2D

func _ready() -> void:
	assert(line_a)
	assert(line_b)

func _process(delta: float) -> void:
	var new_points : PackedVector2Array = []
	for point : Vector2 in line_a.points:
		new_points.append(point)
	for i : int in range(line_b.points.size()-1,-1,-1):
		new_points.append(line_b.points[i])
	polygon = new_points
	#print(polygon.size())
