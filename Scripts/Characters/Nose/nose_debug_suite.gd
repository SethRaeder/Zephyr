extends Control
class_name NoseDebugSuite

@onready var tickle_bar: ProgressBar = %TickleBar
@onready var burn_bar: ProgressBar = %BurnBar
@onready var sensitivity_bar: ProgressBar = %SensitivityBar

var parent : NoseTriggerZone
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent() is not NoseTriggerZone:
		queue_free()
	else:
		await owner.ready
		parent = get_parent()
		tickle_bar.max_value = parent.tickle.max_value
		burn_bar.max_value = parent.burn.max_value
		sensitivity_bar.max_value = parent.sensitivity.max_value
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	tickle_bar.value = parent.tickle.current_value
	burn_bar.value = parent.burn.current_value
	sensitivity_bar.value = parent.sensitivity.current_value
