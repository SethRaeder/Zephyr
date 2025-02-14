extends Node2D

var centerPos
var speed = 8
@export var radiusBound = 50
var enabled = true
var lerpTickle = 0.0

var eyeJitterTime = 250
var eyeJitterTarget = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	#centerPos = Vector2(32,-7)
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Time.get_ticks_msec() > eyeJitterTime:
		#print("Jitter")
		eyeJitterTime += randf_range(250,750)
		eyeJitterTarget = Vector2.from_angle(randf_range(0,2*PI)) * randf_range(0,5)
		
	if(enabled):
		var mousePos = get_viewport().get_mouse_position()
		centerPos = $"../PupilCenterPos".global_position
		#print(to_global(centerPos))
		var vectorToMouse = centerPos.direction_to(mousePos)
		var mult = min(centerPos.distance_to(mousePos) * 0.45,radiusBound)
		var desired = $"../PupilCenterPos".position + (vectorToMouse * mult)
		
		var movespeed = speed
		if lerpTickle > 0.65:
			desired = lerp($"../PupilForwardPos".position, $"../PupilUpPos".position, (lerpTickle - .65) / .35)
			movespeed = .5 * speed
		elif lerpTickle > 0.4:
			desired = lerp(desired, $"../PupilForwardPos".position, (lerpTickle - .4) / .25)
			movespeed = 0.5 * speed
			
		
		position = position.lerp(desired + eyeJitterTarget,delta * movespeed)
	else:
		position = $"../PupilForwardPos".position

func _on_sneeze_manager_tickle(val):
	if val > 0:
		lerpTickle = val
	else:
		lerpTickle = 0

func _on_sneeze_manager_idle():
	lerpTickle = 0
