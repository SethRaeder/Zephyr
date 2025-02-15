extends Area2D
class_name TickleComponent

@export_category("Tickle Type")
#enum DAMAGE_TYPES {RUB, FLUFF, POKE, POLLEN, DUST, CHHINKNI, }
enum DAMAGE_TYPES {TICKLE, BURN, ALLERGY}

## Tickle decays faster than burn
@export var tickle_type : DAMAGE_TYPES = DAMAGE_TYPES.TICKLE

@export var allergy_type : AllergyResource
## Amount of tickle to add per second
@export var intensity : float = 1
## Total amount of tickle this object can give over its lifetime
@export var tickle_damage_limit : float = -1
#Keep track of the current damage inflicted
var total_tickle_damage : float = 0

## Multiplier to the intensity as damage limit is used up.
@export var tickle_damage_curve : Curve = preload("res://Scenes/Components/Tools/default_tickle_damage_curve.tres")

@export_category("Velocity Settings")
@export var use_velocity : bool
@export var max_speed : float = 500
@export var velocity_curve : Curve

var targeted_area : Area2D

#signal tickle_damage_percent(percent : float)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
func _physics_process(delta: float) -> void:
	if targeted_area:
		var tickle_amount = get_tickle() * delta
			
		#Add tickle to targeted area
		if tickle_amount > 0:
			total_tickle_damage += tickle_amount
			targeted_area.add_tickle(tickle_amount, tickle_type)
			#tickle_damage_percent.emit(total_tickle_damage / tickle_damage_limit)

func get_tickle():
	var tickle_amount = intensity
	
	#Modify tickle amount by durability and velocity.
	tickle_amount *= get_durability_sample()
	tickle_amount *= get_velocity_sample()
	return tickle_amount

## Return the float multiplier on tickle amount depending on tool velocity.
func get_velocity_sample() -> float:
	if not use_velocity:
		return 1.0
	return velocity_curve.sample(clampf(get_parent().linear_velocity.length() / max_speed, 0.0, 1.0))

## Return the float multiplier on tickle amount depending on durability curve.
func get_durability_sample() -> float:
	if tickle_damage_limit < 0:
		return 1.0
	
	return tickle_damage_curve.sample(clampf(total_tickle_damage/tickle_damage_limit,0,1))


func _on_area_entered(area: Area2D) -> void:
	#print("TickleComponent: Area Entered")
	if area.has_method("add_tickle"):
		#print("Targeting area...")
		targeted_area = area

func _on_area_exited(area: Area2D) -> void:
	if area == targeted_area:
		#print("Leaving targeted area")
		targeted_area = null
