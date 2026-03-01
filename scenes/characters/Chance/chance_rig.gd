@tool
extends Node

@onready var tongue_control: PathCurler = %TongueControl
@export_range(-5,5) var tongue_curl : float = 0:
	set(new):
		tongue_curl = new
		tongue_control.curve_drivers[1].y = new

@export_range(640,2000,1.0) var tongue_length : float = 650:
	set(new):
		tongue_length = new
		tongue_control.path_length = new
