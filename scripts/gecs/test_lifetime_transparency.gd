extends Sprite2D

func _process(delta: float) -> void:
	var parent : Node = get_parent()
	if parent is Entity:
		if parent.has_component(C_Lifetime):
			var lifetime : C_Lifetime = parent.get_component(C_Lifetime)
			modulate.a = clampf(lifetime.time, 0, 1)
