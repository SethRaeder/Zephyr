extends Label
@export var brain : Brain


func _process(delta: float) -> void:
	var contents = ""
	for entry in brain.anim_parameters:
		#if brain.anim_parameters[entry]:
		contents += "%s : %s\n"%[entry,brain.anim_parameters[entry]]
	text = contents
