extends Node

@export var eye_target : Marker2D
@export var pupil_bone : Bone2D

enum TRACK_MODE {MOUSE, NOSE, ROLL, ANIMATION}
@export var mode = TRACK_MODE.MOUSE

var look_vector = Vector2.ZERO
var target_position = Vector2.ZERO
var update_time : float = .4
var _update_timer : Timer

@export var look_roll_back_target: Marker2D
@export var look_at_nose_target: Marker2D

func _ready():
	assert(look_at_nose_target)
	assert(look_roll_back_target)
	assert(pupil_bone)
	assert(eye_target)
	
	_update_timer = Timer.new()
	add_child(_update_timer)
	_update_timer.wait_time = update_time
	
	_update_timer.timeout.connect(_update_target_position)
	_update_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if mode == TRACK_MODE.ANIMATION:
		return
	
	eye_target.global_position = lerp(eye_target.global_position, target_position, 0.1)
	look_vector = eye_target.global_position - pupil_bone.global_position
	pupil_bone.position = (look_vector / 3.0).limit_length(60);

func _update_target_position():
	match(mode):
		TRACK_MODE.MOUSE:
			#Lerp eye target towards mouse on every frame
			target_position = get_viewport().get_mouse_position()
		TRACK_MODE.NOSE:
			#Lerp eye target towards mouse on every frame
			target_position = look_at_nose_target.global_position
		TRACK_MODE.ROLL:
			#Lerp eye target towards mouse on every frame
			target_position = look_roll_back_target.global_position
