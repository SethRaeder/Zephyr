extends Resource
class_name CustomBoundedValue

@export var name: StringName
@export var min_value : float
@export var max_value : float
@export var current_value : float
#
#func _init(_name, _min, _max, _current) -> void:
	#name = _name
	#min_value = _min
	#max_value = _max
	#current_value = _current

signal hit_max()
signal hit_min()

func get_percent() -> float:
	return (current_value-min_value)/(max_value-min_value)
	
func add_value(delta) -> void:
	set_value(current_value + delta)

func set_value(new_value) -> void:
	current_value = new_value
	if current_value > max_value:
		hit_max.emit()
		#print(name," Hit Max")
		current_value = max_value
		
	elif current_value < min_value:
		hit_min.emit()
		#print(name," Hit Min")
		current_value = min_value
	
	emit_changed()

func _to_string() -> String:
	return "%s: %.2f %.2f" % [name, current_value, get_percent()]
