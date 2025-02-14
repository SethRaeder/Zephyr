extends Marker2D
class_name WindOrigin

@export var lungs : Lungs
@export var wind_strength : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if lungs:
		lungs.breathe_rate.connect(func(rate : float):
			wind_strength = rate * 1000000
		)
