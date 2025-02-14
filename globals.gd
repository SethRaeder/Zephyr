extends Node

var randSneezeButton
var toolSwapButton
var defaultButton
var randomButton

var SNEEZE = {
	'max' : 100.0,
	'min' : 0.0,
	'value': 0.0,
	'tickleThreshold': 0.3,
	'hitchThreshold': 0.85,
	'threshold': 0.99,
	'fitThreshold': 0.5,
	'tickleDecayRate' : 300,
	'burnDecayRate' : 60,
}

var SNEEZESIZE = {
	'max': 1.0,
	'min': 0.2,
	'value': 0.2,
	'average': 0.6,
	'controlledAverage' : 0.3
}


var sensitivity = 1.0
var minSensitivity = 0.25
var maxSensitivity = 5.0

var CONTROL = {
	'max' : 1.0,
	'min' : 0.0,
	'value' : 1.0,
	'regen' : 0.1,
	'decay' : 0.5,
	'fireThreshold' : 0.3,
	'smokeThreshold' : 0.6,
	'smokeTrailThreshold' : 0.1,
}

var irritationValue = 0.0
var irritationMax = 100.0
var irritationInfluence =  SNEEZE['max'] / 5.0
var sneezeValueDecay = SNEEZE['max'] / 40.0
var irritationDecay = irritationMax / 60.0



var hitchiness = 1.0



var sneezeSizeErrRate = SNEEZESIZE['max']/5.0
var sneezeSizeDecayRate = SNEEZESIZE['max']/3.0
var sneezeSizePassiveRate = SNEEZESIZE['max']/20.0

var FIRE = {
	'max' = 100.0,
	'min' = 0.0,
	'value' = 100.0,
	'regen' = 0.025,
	'useRate' = 100.0,
	'irritationDecay' = 0.5,
	'tickleDecay' = 0.5,
	'particleDecay' = 8.0,
	'allergyDecay' = 0.2,
}

var nosePosition

var lungCapacity = 100.0
var breathSpeedMultiplier = 1.0
var lungThreshold = 0.8
var lungMinThreshold = 0.2
var lungIdleThreshold = .6
var lungCurrent = 0.0

var tool_locked = false

#Name, Color, HP, Size, Mass, Tickle, Irritation, Decay
var PARTICLETYPES = [
	preload("res://Scenes/old_project/Tools/resources/particles/dustParticle.tres"),
	preload("res://Scenes/old_project/Tools/resources/particles/pollenParticle.tres"),
	preload("res://Scenes/old_project/Tools/resources/particles/powderParticle.tres"),
	preload("res://Scenes/old_project/Tools/resources/particles/chhinkniParticle.tres")
]

var PARTICLEWEIGHTS = {
	"dust": 1.0,
	"chhinkni": 1.0,
	"powder": 1.0,
	"pollen": 1.0
}

var ALLERGIES = {
	"dust": 0.0,
	"pollen": 1.0,
}

var NOSEWEIGHTS = {
	"tickle": 1.0,
	"burn": 1.0
}

const allergyRateMax = 3
var allergyValue = 0.0
const allergyMax = 100.0
var allergyIrrValue = irritationMax / 20.0
var allergyTickleValue = SNEEZE['max'] / 10.0
var allergyTime = 20.0

var particleAmounts = []

var sneezeParticleFactor = 1.25

var coldIntensity = 0.0
var coldMax = 100.0
var coldIrrInfluence = irritationMax / 180.0
var coldSensInfluence = maxSensitivity / 10.0
var coldTickleInfluence = SNEEZE['max'] / 180.0

var messValue = 0.0
var messMax = 100.0
var messMultiplier = 1.0
var messIrrRate = messMax / 30.0
var messPassiveRate = -messMax / 120.0
var messAllergyRate = messMax / 15.0
var messColdRate = messMax / 15.0
var messSneezeRate = -messMax / 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	return
	#randomSettings()
	defaultSettings()
	for i in range(PARTICLETYPES.size()):
		particleAmounts.append(0.0)

var firstTick = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	return
	if(firstTick):
		defaultButton.connect("pressed",defaultSettings)
		randomButton.connect("pressed",randomSettings)
		firstTick = false
		
	lungCurrent = clamp(lungCurrent, 0, lungCapacity)
	sensitivity = clampf(sensitivity, minSensitivity, maxSensitivity)
	allergyValue -= allergyMax * delta/allergyTime
	allergyValue = clamp(allergyValue, 0, allergyMax)
	
	var messDelta = (messIrrRate * getIrritationPercent()) + (messColdRate * getColdPercent()) + (messPassiveRate) + (messAllergyRate * getAllergyPercent())
	messValue += messDelta * delta
	messValue = clamp(messValue,0,messMax)
	
	addIrritation(getAllergyPercent() * allergyIrrValue * delta)
	addSneezeValue(getAllergyPercent() * allergyTickleValue * delta)
	addIrritation(getColdPercent() * coldIrrInfluence * delta)
	addSneezeValue(getColdPercent() * coldTickleInfluence * delta)
	sensitivity += coldSensInfluence * getColdPercent() * delta
	
	sensitivity += (maxSensitivity / 30.0) * (1 - sensitivity) * delta

	for i in range(particleAmounts.size()):
		var type:Particle_Resource = PARTICLETYPES[i]
		var d = particleAmounts[i] * delta / type.decay
		particleAmounts[i] -= d
		#print("Particle ", i, ": ", particleAmounts[i])
		if(particleAmounts[i] < 0.01):
			particleAmounts[i] = 0
				
		var num = log(particleAmounts[i] + 1)
		#print(num)
		if(num > 0):
			if(ALLERGIES.has(type.name)):
				print("Allergy Triggered ",i," ",type.name)
				allergyValue += ALLERGIES[type.name] * num * delta
		
			addIrritation(PARTICLEWEIGHTS[type.name] * num * type.irritation * delta)
			addSneezeValue(PARTICLEWEIGHTS[type.name] * num * type.tickle * delta)
	pass

func defaultSettings():
	NOSEWEIGHTS["tickle"] = 1.0
	NOSEWEIGHTS["burn"] = 1.0
	PARTICLEWEIGHTS["dust"] = 1.0
	PARTICLEWEIGHTS["powder"] = 1.0
	PARTICLEWEIGHTS["chhinkni"] = 1.0
	ALLERGIES["dust"] = allergyRateMax / 3
	ALLERGIES["pollen"] = allergyRateMax
	coldIntensity = 0.0
	messMultiplier = 1.0
	SNEEZESIZE['min'] = 0.2
	SNEEZESIZE['max'] = 1.0
	SNEEZESIZE['average'] = 0.5
	hitchiness = 1.0
	SNEEZE['controlledAverage'] = 0.3
	SNEEZE['burnDecayRate'] = 60 #0-100
	SNEEZE['tickleDecayRate'] = 300 #0-500
	
func randomSettings():
	NOSEWEIGHTS["tickle"] = randf_range(0.3,2.5)
	NOSEWEIGHTS["burn"] = randf_range(0.3,2.5)
	PARTICLEWEIGHTS["dust"] = randf_range(0.3,2.5)
	PARTICLEWEIGHTS["powder"] = randf_range(0.3,2.5)
	PARTICLEWEIGHTS["chhinkni"] = randf_range(0.3,2.5)
	ALLERGIES["dust"] = randf_range(0.5, allergyRateMax) if (randf() <= 0.3) else 0.0
	ALLERGIES["pollen"] = randf_range(0.5, allergyRateMax) if (randf() <= 0.5) else 0.0
	coldIntensity = randf_range(0.3,coldMax) if (randf() <= 0.25) else 0.0
	messMultiplier = randf_range(0.3,2.5)
	SNEEZESIZE['min'] = randf_range(0.2,1.0)
	SNEEZESIZE['max'] = randf_range(SNEEZESIZE['min'],1.0)
	SNEEZESIZE['average'] = randf_range(SNEEZESIZE['min'],SNEEZESIZE['max'])
	hitchiness = randf_range(0.2,3.0)
	SNEEZESIZE['controlledAverage'] = randf_range(SNEEZESIZE['min'],SNEEZESIZE['max'])
	SNEEZE['burnDecayRate'] = randf_range(10,90) #0-100
	SNEEZE['tickleDecayRate'] = randf_range(10,490) #0-500

func getParticleColor(type):
	return PARTICLETYPES[type].color
	
func getParticleSize(type):
	return PARTICLETYPES[type].max_size
	
func getSneezeLimit(isFit: bool):
	return SNEEZE['max'] * SNEEZE['fitThreshold'] if isFit else SNEEZE['max'] * SNEEZE['threshold']

func getHitchLimit():
	return SNEEZE['max'] * SNEEZE['hitchThreshold']
	
func getTickleLimit():
	return SNEEZE['max'] * SNEEZE['tickleThreshold']

func getTicklePercent():
	return clamp((Globals.SNEEZE['value'] - getTickleLimit()) / (getHitchLimit() - getTickleLimit()),0,1)

func getIrritationPercent():
	return irritationValue / irritationMax

func getColdPercent():
	return coldIntensity / coldMax
	
func getMessPercent():
	return (messValue / messMax) * messMultiplier

func getAllergyPercent():
	return allergyValue / allergyMax
		
func doSneeze(delta):
	messValue += SNEEZESIZE['value'] * messSneezeRate * delta

func doMess(amount):
	pass

func useFire(delta):
	var firePercent = lerpf(1.0 ,0.25, FIRE['value'] / FIRE['max']) * lerpf(1.0, 0, CONTROL['value'] / CONTROL['fireThreshold']) * Globals.SNEEZESIZE['value'] if CONTROL['value'] < CONTROL['fireThreshold'] else 0
	#print("Fire Percent: ",firePercent)
	if(FIRE['value'] <= FIRE['max'] * 0.01):
		firePercent = 0
	
	firePercent = clamp(firePercent,0.0,1.0)
	FIRE['value'] -= firePercent * FIRE['useRate'] * delta
	
	irritationValue -= irritationMax * FIRE['irritationDecay'] * firePercent * delta
	SNEEZE['value'] -= SNEEZE['max'] * FIRE['tickleDecay'] * firePercent * delta
	allergyValue -= allergyMax * FIRE['allergyDecay'] * firePercent * delta
	for i in range(particleAmounts.size()):
		particleAmounts[i] -= particleAmounts[i] * firePercent * FIRE['particleDecay'] * delta
	
	return firePercent

func regenFire(delta):
	FIRE['value'] = clamp(FIRE['value'] + (FIRE['max'] * FIRE['regen'] * delta),0,FIRE['max'])

func regenControl(delta):
	CONTROL['value'] += CONTROL['decay'] * CONTROL['regen'] * delta
	CONTROL['value'] = clamp(CONTROL['value'],CONTROL['min'],CONTROL['max'])
	
func decayControl(delta):
	CONTROL['value'] -= CONTROL['decay'] * delta * SNEEZESIZE['value']
	CONTROL['value'] = clampf(CONTROL['value'],CONTROL['min'],CONTROL['max'])

func addParticle(type:Particle_Resource, amount:float):
	var index = PARTICLETYPES.find(type)
	particleAmounts[index] += amount
	pass

func particleSneezeDecay(delta):
	for i in range(particleAmounts.size()):
		var type = PARTICLETYPES[i]
		var d = particleAmounts[i] * sneezeParticleFactor * delta / type.decay
		particleAmounts[i] -= d
	pass

func addSneezeValue(amount):
	amount = amount * Globals.sensitivity if amount > 0 else amount
	SNEEZE['value'] = clamp(SNEEZE['value'] + (amount * NOSEWEIGHTS["tickle"]),0,SNEEZE['max'])

func addIrritation(amount):
	amount = amount * Globals.sensitivity if amount > 0 else amount
	irritationValue = clamp(irritationValue + (amount * NOSEWEIGHTS["burn"]),0,irritationMax)

func decaySneezeValue(delta,sneezing:bool):
	SNEEZE['value'] -= SNEEZE['tickleDecayRate'] * SNEEZESIZE['value'] * delta if sneezing else sneezeValueDecay * delta
	SNEEZE['value'] = clamp(SNEEZE['value'],SNEEZE['min'],SNEEZE['max'])

func decayIrritationValue(delta,sneezing:bool):
	irritationValue -= SNEEZE['burnDecayRate'] * SNEEZESIZE['value'] * delta if sneezing else irritationDecay * delta
	irritationValue = clamp(irritationValue,0,irritationMax)

func adjustSneezeSize(target,delta,rate):
	SNEEZESIZE['value'] = move_toward(SNEEZESIZE['value'],target,delta * rate)
	SNEEZESIZE['value'] = clamp(SNEEZESIZE['value'],0,1)
	
func lungSneezeReady(isFit):
	if(isFit):
		return lungCurrent >= (lungCapacity * lungMinThreshold)
	return lungCurrent >= (lungCapacity * lungThreshold)
	
func canBreatheIn():
	return lungCurrent < lungCapacity
	
func canBreatheOut():
	return lungCurrent > 0
