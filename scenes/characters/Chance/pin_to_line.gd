@tool
extends Node2D

@export var line : Line2D
@export_range(0,1,0.01) var pin_percentage : float
@export var position_offset : Vector2
@export var rotation_offset : float

var print_counter : int = 0

func _process(_delta: float) -> void:
	if line:
		var index : int = lerp(0,line.get_point_count()-1,pin_percentage)
		var tangent_start : Vector2 = position
		var tangent_end : Vector2 = position
		if index > 0:
			tangent_start = line.get_point_position(index - 1)
		if index < line.get_point_count() - 1:
			tangent_end = line.get_point_position(index + 1)
		
		#var tangent_normal : Vector2 = tangent_start.direction_to(tangent_end).rotated(PI/2).normalized()
		position = line.get_point_position(index) + (position_offset.rotated(tangent_start.direction_to(tangent_end).angle()))
		rotation = tangent_start.direction_to(tangent_end).angle() + rotation_offset
		
		#print_counter += 1
		#if print_counter > 50:
			#print("Pin positions : (%s) %s | (%s) %s \n Angle: %s"%[index-1,tangent_start,index+1,tangent_end,tangent_start.angle_to(tangent_end)])
			#print_counter = 0
