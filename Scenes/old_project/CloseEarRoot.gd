extends Node2D

func _spreadEar(enable: bool):
	$CloseEar.visible = !enable
	$CloseEarSneeze.visible = enable
