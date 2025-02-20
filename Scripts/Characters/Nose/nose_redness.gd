extends Sprite2D
class_name NoseRedness

@export var tracked_nose : NoseTriggerZone
@export var tickle_factor : float = 0.2
@export var burn_factor : float = 0.3
@export var fade_seconds : float = 2.0
func _ready() -> void:
	modulate.a = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	modulate.a = lerpf(modulate.a,(tracked_nose.tickle.get_percent() * tickle_factor) + (tracked_nose.burn.get_percent() * burn_factor), delta / fade_seconds)
