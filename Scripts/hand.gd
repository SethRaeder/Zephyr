extends Node2D
class_name HandCursor

var nose_hovering = false
var grab_target : GrabTransform = null

@export var hand_sprite: AnimatedSprite2D
@export var nose_detector: Area2D
@export var anti_tickle: TickleComponent  
@export var anti_burn: TickleComponent

func _ready() -> void:
	ZephyrGlobals.tool_grabbed.connect(_on_tool_grabbed)
	ZephyrGlobals.tool_dropped.connect(_on_tool_released)
	
	if nose_detector:
		nose_detector.area_entered.connect(_on_nose_hover)
		nose_detector.area_exited.connect(_on_nose_unhover)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_instance_valid(ZephyrGlobals.grabbed_tool_ref):
		global_position = grab_target.global_position
		rotation = deg_to_rad(-70) + ZephyrGlobals.grabbed_tool_ref.rotation
		
	else:
		global_position = get_global_mouse_position()
		rotation = lerp_angle(rotation, 0, 10 * delta)
		

func toggle_nose_rub(enabled : bool):
	if anti_burn:
		anti_burn.monitorable = enabled
		anti_burn.monitoring = enabled
	if anti_tickle:
		anti_tickle.monitorable = enabled
		anti_tickle.monitoring = enabled
		
func _on_tool_released():
	if nose_hovering:
		hand_sprite.frame = 2
		toggle_nose_rub(true)
	else:
		hand_sprite.frame = 0
	
func _on_tool_grabbed():
	hand_sprite.frame = 1
	var tool_nodes = ZephyrGlobals.grabbed_tool_ref.get_children()
	for child in tool_nodes:
		if child is GrabTransform:
			grab_target = child
			return

func _on_nose_hover(area):
	if area is NoseTriggerZone:
		print("Hand: Hovering...")
		nose_hovering = true
		if ZephyrGlobals.grabbed_tool_ref:
			return
		else:
			hand_sprite.frame = 2
			toggle_nose_rub(true)

func _on_nose_unhover(area):
	if area is NoseTriggerZone:
		print("Hand: Stopped hovering")
		nose_hovering = false
		toggle_nose_rub(false)
		if ZephyrGlobals.grabbed_tool_ref:
			hand_sprite.frame = 1
		else:
			hand_sprite.frame = 0
