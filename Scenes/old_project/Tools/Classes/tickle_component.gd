extends Area2D

class_name TickleComponent_Deprecated

@export var intensity : float = 10
@export var use_velocity : bool
@export var velocity_curve : Curve
@export var max_speed : float = 50

var targeted_area : Area2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _process(delta: float) -> void:
	if targeted_area:
		targeted_area.add_tickle(get_tickle() * delta)

func get_tickle():
	if(use_velocity):
		var parent : RigidBody2D = get_parent()
		var sample = velocity_curve.sample(clampf(parent.linear_velocity.length() / max_speed, 0.0, 1.0))
		#print("DEBUG: Tickle Velocity Sample: ",sample)
		return sample * intensity
	else:
		return intensity

func _on_area_entered(area: Area2D) -> void:
	#print("TickleComponent: Area Entered")
	if area.has_method("add_tickle"):
		#print("Area has Tickle Method")
		targeted_area = area

func _on_area_exited(area: Area2D) -> void:
	if area == targeted_area:
		#print("Leaving targeted area")
		targeted_area = null
