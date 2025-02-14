extends Area2D

class_name IrritationComponent_Deprecated

@export var intensity : float = 5
@export var use_velocity : bool
@export var velocity_curve : Curve
@export var max_speed : float = 50


var targeted_area : Area2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _process(delta: float) -> void:
	if targeted_area:
		targeted_area.add_burn(get_burn() * delta)

func get_burn():
	if(use_velocity):
		var parent : RigidBody2D = get_parent()
		var sample = velocity_curve.sample(parent.linear_velocity.length() / max_speed)
		#print(parent.linear_velocity.length())
		return  sample * intensity
	else:
		return intensity

func _on_area_entered(area: Area2D) -> void:
	#print("BurnComponent: Area Entered")
	if area.has_method("add_burn"):
		#print("Area has Burn Method")
		targeted_area = area

func _on_area_exited(area: Area2D) -> void:
	if area == targeted_area:
		#print("Leaving targeted area")
		targeted_area = null
