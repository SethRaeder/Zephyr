extends Node

func _ready() -> void:
	print("%s ready at %s"%[name,Time.get_ticks_usec()])
