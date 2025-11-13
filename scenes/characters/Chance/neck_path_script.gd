@tool
extends Path2D

@export var tracked_bones : Array[Node2D]
@export var smoothing : float = 1000
func _ready() -> void:
	curve.clear_points()
	for bone in tracked_bones:
		curve.add_point(bone.global_position)

func _process(_delta: float) -> void:
	for i in range(tracked_bones.size()):
		curve.set_point_position(i,tracked_bones[i].global_position)
		var tangent_start = tracked_bones[i].global_position
		var tangent_end = tracked_bones[i].global_position
		if i > 0:
			tangent_start = tracked_bones[i-1].global_position
			
		if i < tracked_bones.size() - 1:
			tangent_end = tracked_bones[i+1].global_position
		var slope = tangent_start.direction_to(tangent_end)
		
		#Set tangent points.
		curve.set_point_in(i,-slope * smoothing)
		curve.set_point_out(i, slope * smoothing)
