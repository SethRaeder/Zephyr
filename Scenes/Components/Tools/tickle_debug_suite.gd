extends Control
class_name TickleDebugSuite

@onready var tickle_intensity_bar: ProgressBar = %TickleIntensityBar
@onready var tickle_durability_bar: ProgressBar = %TickleDurabilityBar

var parent : TickleComponent

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent() is not TickleComponent:
		queue_free()
	else:
		parent = get_parent()
		match parent.tickle_type:
			TickleComponent.DAMAGE_TYPES.TICKLE:
				tickle_intensity_bar.modulate = Color.AQUA
			TickleComponent.DAMAGE_TYPES.BURN:
				tickle_intensity_bar.modulate = Color.RED
		
		if parent.tickle_damage_limit < 0:
			tickle_durability_bar.hide()
				
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	tickle_durability_bar.value = parent.get_durability_sample()
	tickle_intensity_bar.value = parent.get_tickle() / parent.intensity
