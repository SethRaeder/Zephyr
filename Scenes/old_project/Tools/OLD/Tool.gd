extends Node2D

class ToolMode:
	#Velocity tickle, passive tickle, velocity irritation, passive irritation
	var tool_name:String
	var tickle_vel: float
	var tickle_passive: float
	var irr_vel: float
	var irr_passive: float
	var particle_name:String
	var particle_velocity:float
	var particle_rate
	
	func _init(nm:String, tv: float, tp: float, iv: float, ip: float, pn:String, vel:float, rate):
		tool_name = nm
		tickle_passive = tp
		tickle_vel = tv
		irr_vel = iv
		irr_passive = ip
		particle_name = pn
		self.particle_velocity = vel
		particle_rate = rate

var nextParticleTime = 0
		
const SPEED = 15
var tilt = 0.0
var spring = 10

var toolList = [
	ToolMode.new("Feather", 1.5, 3, 0.25, 0.25, "", 0, 0),
	ToolMode.new("Paintbrush", 2.5, 5, 1.0, 0, "", 0, 0),
	ToolMode.new("Duster", 1.5, 0.0, 0.25, 2.0, "dust", 15, 30),
	ToolMode.new("Flower", 0.2, 0, 0, 4, "pollen", 20, 30),
	ToolMode.new("Powder", 2, 1, 0, 4, "powder", 15, 30),
	ToolMode.new("Chhinkni", 0, 0, 0, 10.0, "chhinkni", 15, 30),
	ToolMode.new("Hand", -3, -12, 0, 0, "", 0, 0),
]


var currentTool: ToolMode
var trailing = false
var desirePosition = Vector2.ZERO
var lastMouse = Vector2.ZERO
var mousePos = Vector2.ZERO
@export var velocity = Vector2(0,0)
# Called when the node enters the scene tree for the first time.
func _ready():
	position = get_viewport().get_mouse_position()
	currentTool = toolList[0]
	switchTool(0)
	Globals.toolSwapButton.connect("pressed",nextTool)
	pass # Replace with function body.
	
func _process(delta):
	if Input.is_action_just_released("next tool"):	
		nextTool()
	elif Input.is_action_just_released("last tool"):
		prevTool()
	
	if Input.is_action_just_pressed("lock tool"):
		Globals.tool_locked = !Globals.tool_locked
		
	lastMouse = mousePos
	mousePos = get_viewport().get_mouse_position()
		
	if(Globals.tool_locked):
		var offset = get_node(currentTool.tool_name).get_child(0).global_position - global_position
		var diff = SPEED/3*(mousePos - lastMouse)
		#print(offset)
		desirePosition = lerp(desirePosition, diff+  Globals.nosePosition - offset, delta * SPEED/3)
	else:
		desirePosition = mousePos	
	
	if Input.is_action_just_pressed("tool 1"):
		switchTool(0)
	if Input.is_action_just_pressed("tool 2"):
		switchTool(1)
	if Input.is_action_just_pressed("tool 3"):
		switchTool(2)
	if Input.is_action_just_pressed("tool 4"):
		switchTool(3)
	if Input.is_action_just_pressed("tool 5"):
		switchTool(4)
	if Input.is_action_just_pressed("tool 6"):
		switchTool(5)
	if Input.is_action_just_pressed("tool 7"):
		switchTool(6)
#	if Input.is_action_just_pressed("tool 8"):
#		switchTool(tools[7])
	
	
	var diff = position - desirePosition
	
	var newPos = position.lerp(desirePosition, delta * min(SPEED,diff.length()/2))
	velocity = position - newPos
	#print(velocity.length())
	position = newPos
	rotation = lerpf(rotation, velocity[0] * delta, delta * spring)
	
	if(velocity.length() >= currentTool.particle_velocity):
		trailing = true
	elif(velocity.length() <= 0.7 * currentTool.particle_velocity):
		trailing = false
		
	if trailing:
		#if(toolValues[currentTool][4] != null):
		var now = Time.get_ticks_msec()
		if(currentTool.particle_name != "" and now > nextParticleTime):
			nextParticleTime = now + 1000/currentTool.particle_rate
			$ParticleSpawner.spawnParticle(currentTool.particle_name,-velocity*0.8,get_node(currentTool.tool_name).get_child(0).global_position)

func switchTool(index):
	
	get_node(currentTool.tool_name).get_child(0).get_child(0).set_deferred("disabled",true)
	get_node(currentTool.tool_name).visible = false
	
	currentTool = toolList[index]
	
	get_node(currentTool.tool_name).visible = true
	get_node(currentTool.tool_name).get_child(0).get_child(0).set_deferred("disabled",false)
	
func nextTool():
	var i = toolList.find(currentTool) + 1
	if (i >= len(toolList)):
		i = 0
	switchTool(i)

func prevTool():
	var i = toolList.find(currentTool) - 1
	if (i < 0):
		i = len(toolList) - 1
	switchTool(i)
	
func get_tickle():
	return (velocity.length() * currentTool.tickle_vel) + currentTool.tickle_passive
	
func get_burn():
	return (velocity.length() * currentTool.irr_vel) + currentTool.irr_passive

