extends Area2D

var irritation = 0
var mouseEntered = false

@onready var player := $"../AnimationTree"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	player.advance(delta)
	
	if mouseEntered:
		irritation += delta * 20
		if irritation > 100: irritation = 100
	else:
		irritation -= delta * 10
		if irritation < 0: irritation = 0
	
	player.set("parameters/conditions/i-t", irritation > 30)
	player.set("parameters/conditions/t-i", irritation < 20)
	player.set("parameters/conditions/t-h", irritation > 80)
	player.set("parameters/conditions/h-t", irritation < 60)
	player.set("parameters/conditions/sneeze", irritation >= 100)

	print(irritation)
	if irritation >= 100:
		irritation -= randi_range(0,50)	
	
func _mouse_enter():
		mouseEntered = true

func _mouse_exit():
		mouseEntered = false
	
	
