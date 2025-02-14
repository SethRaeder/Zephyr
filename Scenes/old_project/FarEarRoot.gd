extends Node2D

func spreadEar(enable: bool):
	$FarEar.visible = !enable;
	$FarEarSneeze.visible = enable;
