extends Node2D
class_name EmitOnBreatheComponent

enum BREATHE_TYPE {IN, OUT, BOTH}
##Which breathe type should this be enabled on?
@export var enabled_on_breath_type : BREATHE_TYPE = BREATHE_TYPE.IN
@export var local_wind_strength_threshold : float = 100
@export var local_wind_strength_max : float = 100
@export var wind_spawn_curve : Curve

@export var wind_subscriber : WindSubscriber
var breath_type_match : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for node in get_tree().get_nodes_in_group("lungs"):
		if node is Lungs:
			node.breathe_rate.connect(on_breathe)

func _physics_process(_delta: float) -> void:
	if breath_type_match:
		var windspeed = wind_subscriber.wind_vector.length()
		if windspeed >= local_wind_strength_threshold:
			#print("Emit On Breathe : Wind Speed ", windspeed)
			var wind_percent = clampf(windspeed  - local_wind_strength_threshold, 0.0, local_wind_strength_max - local_wind_strength_threshold) / (local_wind_strength_max  - local_wind_strength_threshold)
			if randf() < wind_spawn_curve.sample(wind_percent):
				get_parent().spawn_particle()

func on_breathe(rate : float):
	if rate > 0:
		match enabled_on_breath_type:
			BREATHE_TYPE.IN, BREATHE_TYPE.BOTH:
				breath_type_match = true
			_:
				breath_type_match = false

	elif rate < 0:
		match enabled_on_breath_type:
			BREATHE_TYPE.OUT, BREATHE_TYPE.BOTH:
				breath_type_match = true
			_:
				breath_type_match = false
	else:
		breath_type_match = false
