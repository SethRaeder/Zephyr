extends Node2D

@onready var handle :Node2D = $"../.."
var default_rotation : float
var stiffness : float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	default_rotation = rotation
	handle.move.connect(move)
	stiffness = randf_range(0.01,0.03)
	
func move(movement:Vector2, _delta):
	#var dot = lerp(-1,1,movement.normalized().dot(Vector2.RIGHT.rotated(rotation))) * (movement.length()/50.0)
	rotation = lerp(default_rotation + stiffness, default_rotation - stiffness, (movement.x+movement.y)/50.0)
