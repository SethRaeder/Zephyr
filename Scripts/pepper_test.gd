extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	
	move_and_collide((get_viewport().get_mouse_position() - global_position))
	
	#rotation = rotate_toward(rotation, linear_velocity.angle() + 1.57, 0.1);
