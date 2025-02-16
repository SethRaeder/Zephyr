extends Marker2D

@onready var look_roll_back_target: Marker2D = %LookRollBackTarget
@onready var look_at_nose_target: Marker2D = %LookAtNoseTarget

var target_position = Vector2.ZERO
var update_ticks = 30
var update_count = 0

enum TRACK_MODE {MOUSE, NOSE, ROLL}
@export var mode = TRACK_MODE.MOUSE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	match(mode):
		TRACK_MODE.MOUSE:
			#Lerp eye target towards mouse on every frame
			update_count = update_count + 1
			if update_count > update_ticks :
				target_position = get_global_mouse_position()
				update_count = 0
		TRACK_MODE.NOSE:
			#Lerp eye target towards mouse on every frame
			target_position = look_at_nose_target.global_position
		TRACK_MODE.ROLL:
			#Lerp eye target towards mouse on every frame
			target_position = look_roll_back_target.global_position
	
	global_position = lerp(global_position, target_position, 0.1)
