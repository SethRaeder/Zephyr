extends Node2D


@onready var FireSmoke = $FireSmoke
@onready var sprayParticle = $spray
@onready var mistParticle = $mist
var enabled = false

var fireAmount:float = 0
var sprayAmount:float = 0
var mistAmount:float = 0

func fire(val:bool):
	enabled = val
	if(val):
		if(fireAmount > 0):
			FireSmoke.amount_ratio = fireAmount
			FireSmoke.emitting = true
	else:
		FireSmoke.emitting = false

func spray(val:bool):
	if(val):
		if(sprayAmount > 0):
			sprayParticle.amount_ratio = sprayAmount
			sprayParticle.emitting = true
				
	else:
		sprayParticle.emitting = false
				

func mist(val:bool):
	if(val):
		if(mistAmount > 0):
			mistParticle.amount_ratio = mistAmount
			mistParticle.emitting = true
	else:
		mistParticle.emitting = false

func _set_fire_amount(val):
	fireAmount = clamp(val,0.0,1.0)

func _set_smoke_amount(val):
	$NostrilTrails.amount_ratio = val
	$NostrilTrails.emitting = true

func _set_nose_fire_amount(val):
	if(enabled):
		$NostrilTrailsSneeze.amount_ratio = val
		$NostrilTrailsSneeze.emitting = true
	else:
		$NostrilTrailsSneeze.emitting = false

func _set_smoke_breathe_amount(val):
	$NostrilTrails_Breathe.amount_ratio = val
	$NostrilTrails_Breathe.emitting = true

func _set_spray_amount(val):
	sprayAmount = clamp(val,0.0,1.0)
	mistAmount = clamp(val,0.0,1.0)

func _on_sneeze_done():
	$NostrilTrailsSneeze.emitting = false
	FireSmoke.emitting = false
	mistParticle.emitting = false
	sprayParticle.emitting = false
