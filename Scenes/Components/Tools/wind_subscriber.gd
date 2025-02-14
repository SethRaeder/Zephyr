extends Node2D


#Wind component must:
  #have boolean for trigger on breathe in
  #have boolean for trigger on breathe out
  #recieve nose breathe event
	#emit wind vector signal depending on wind component transform relative to wind direction and nose transform
	  #wind magnitude depends on nose wind magnitude/distance to nose from wind component
	  #wind direction lerps between (nose wind direction, towards/away from nose) depending on the dot product of nose transform forward, and direction of nose transform to wind component transform

@export var do_breathe_in : bool
@export var do_breathe_out : bool

signal wind_vector(wind:Vector2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
