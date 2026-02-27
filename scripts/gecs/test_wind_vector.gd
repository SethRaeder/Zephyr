extends Sprite2D

var wind_listener : C_CanBeBlown

func _ready() -> void:
	scale.x = 0

func _process(delta: float) -> void:
	var parent : Node = get_parent()
	if parent is Entity:
		if parent.has_component(C_CanBeBlown):
			wind_listener = parent.get_component(C_CanBeBlown)
			rotation = wind_listener.last_wind_vector.angle()
			scale.x = wind_listener.last_wind_vector.length()
