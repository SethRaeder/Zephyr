extends Node2D

enum SNEEZESTATES {IDLE, TICKLE, HITCH, SNEEZE}
@export var state = SNEEZESTATES.IDLE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$HeadSneeze.visible = state == SNEEZESTATES.SNEEZE
	$HeadHitch.visible = state == SNEEZESTATES.HITCH
	$HeadTickle.visible = state == SNEEZESTATES.TICKLE
	$HeadIdle.visible = state == SNEEZESTATES.IDLE
