extends RigidBody2D

@export var holdback_on : bool
var tool_locked = false
var targetedItem : RigidBody2D
var grabbedItem : RigidBody2D

const MAX_SPEED = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func _input(event):
	if event is InputEventMouseButton:
		if event.double_click:
			print("Drop")
			drop_item()
	
		elif event.is_action_pressed("grab"):
			print("grab")
			grab_item()
		
		elif event.is_action_pressed("release"):
			print("Release")
			drop_item()
		
	if event.is_action_pressed("lock tool"):
		tool_locked = not tool_locked


func _physics_process(delta):
	var mouse_location = get_global_mouse_position() #if not tool_locked else lerp(global_position,Globals.nosePosition,.1)
	var distance = mouse_location.distance_to(global_position)
	linear_velocity = Input.get_last_mouse_velocity()
	global_position = mouse_location
	
	
	rotation = lerpf(rotation,lerpf(0,1.0,(linear_velocity.x + linear_velocity.y)/2500.0),0.1)
	
	if grabbedItem:
		grabbedItem.rotation = rotation
		grabbedItem.linear_velocity = linear_velocity
		grabbedItem.move_and_collide(global_position - grabbedItem.global_position)
		
		var distance_vector = global_position - grabbedItem.global_position
		var up_amount = distance_vector.dot(Vector2.UP)
		var right_amount = distance_vector.dot(Vector2.LEFT)
		
		rotation = lerpf(rotation,(up_amount / 5.0) + (right_amount / 5.0),0.1)

func enable_holdback():
	holdback_on = true
	$IrritationComponent.monitorable = true
	$TickleComponent.monitorable = true
	
func disable_holdback():
	holdback_on = false
	$IrritationComponent.monitorable = false
	$TickleComponent.monitorable = false
	
func grab_item():
	if not targetedItem == null:
		grabbedItem = targetedItem
		grabbedItem.global_position = global_position
		grabbedItem.linear_velocity = Vector2(0,0)
		grabbedItem.angular_velocity = 0
		disable_holdback()
		grabbedItem.freeze = true
		print("Grabbed ",grabbedItem)
		

func drop_item():
	if grabbedItem:
		enable_holdback()
		grabbedItem.freeze = false
		grabbedItem = null
	

func _on_grab_hitbox_body_entered(body):
	if body is RigidBody2D:
		print("DEBUG: Hand Target = ",body)
		targetedItem = body




func _on_grab_hitbox_body_exited(body):
	if body == targetedItem:
		targetedItem = null
