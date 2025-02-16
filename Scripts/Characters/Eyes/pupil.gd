extends Bone2D
@onready var eye_target: Marker2D = %"Eye Target"
@onready var eye: Bone2D = $".."

var look_vector = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#Switch based on current eye tracking target.
	
	look_vector = eye_target.global_position-eye.global_position
	
	position = (look_vector / 3.0).limit_length(60);
