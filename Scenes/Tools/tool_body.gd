extends RigidBody2D
class_name SneezeTool
signal move(movement : Vector2)

##Link the sprite to be used for insertion - if null, this tool can't be inserted.
@export var InsertSprite : Sprite2D
@export var collides_with_head_held : bool = false

var grabbed : bool = false
var inserted : bool = false

var tickle_arr = []

func _ready() -> void:
	for child in get_children():
		if child is TickleComponent:
			tickle_arr.append(child)

func _physics_process(delta: float) -> void:
	move.emit(linear_velocity)

	#print("<ToolBody> Speed: ",linear_velocity.length())
	
func grab() -> void:
	print("Grab!")
	grabbed = true
	
	if InsertSprite:
		print("Insert Capable")
		set_collision_mask_value(2,true)
		set_collision_mask_value(1,false)
	elif collides_with_head_held:
		set_collision_mask_value(1,true)
	else:
		set_collision_mask_value(1,false)

func release() -> void:
	print("Release")
	grabbed = false
	
	if not inserted:
		set_collision_mask_value(1,true)
		if InsertSprite:
			set_collision_mask_value(2,false)

func on_nose_remove() -> void:
	inserted = false
	if not grabbed:
		set_collision_mask_value(1,true)
		set_collision_mask_value(2,false)
	
	#Unset the "Inner Nose" Collision flag
	for comp : TickleComponent in tickle_arr:
		comp.set_collision_mask_value(8,false)
		#comp.set_collision_layer_value(8,false)

func on_nose_insert() -> void:
	inserted = true
	
	#Set the "Inner Nose" Collision flag
	for comp : TickleComponent in tickle_arr:
		comp.set_collision_mask_value(8,true)
		#comp.set_collision_layer_value(8,true)
