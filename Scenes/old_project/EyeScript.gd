extends Node2D

enum EYESTATE {IDLE, TICKLE, HITCH, SNEEZE}
@export var currentState = EYESTATE.IDLE
@export var blink: bool = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$Blink.visible = (currentState == EYESTATE.IDLE or currentState == EYESTATE.TICKLE) and blink
	$BlinkToggle.visible = !blink and (currentState == EYESTATE.IDLE or currentState == EYESTATE.TICKLE)
	$BlinkToggle/EyeTickleOutline.visible = currentState == EYESTATE.TICKLE
	$BlinkToggle/EyeIdleOutline.visible = currentState == EYESTATE.IDLE
	$EyeHitch.visible = currentState == EYESTATE.HITCH

func _on_blink_timer_timeout() -> void:
	%BlinkTimer.wait_time = randf_range(0.25,8.0)
	%AnimationTree.set("parameters/blink_shot/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
