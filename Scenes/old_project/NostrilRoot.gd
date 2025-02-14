extends Node2D

func _flare(val:bool):
	$Nostril.visible = !val
	$NostrilWide.visible = val
