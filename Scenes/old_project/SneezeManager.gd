extends Node2D

@export var hitbox: Area2D

var oxygen = 0.0
var oxygenLimit = 6.0
@export var oxygenPerBreath = 0.1

enum SNEEZE {IDLE, TICKLE, HITCH, SNEEZE, WAIT}
enum BREATH {IDLE=0, IN=30, OUT=-50, HITCH=100, SNEEZE=-200, WAIT = -5}
var breathVector = Vector2(1,0)
var sneezeState = SNEEZE.IDLE
@export var breathState = BREATH.IDLE

var tickleComponents = []
var irritationComponents = []

var particleArray: Array

var recovering = false
@onready var redLight = $"../Skeleton2D/LowerNeckRootBone2D/UpperNeckRootBone2D/HeadRootBone2D/NoseHitbox/RedSprite"

var fit_flag = false
var repeat_hitches = false
var nextValidHitchTime = -1
var hitchCooldown = 250 #Milliseconds
var hitchMult = 0.5

var randSneezeTime
var randSneezeDuration
var randSneezeAmount

var numHitches = 0
var maxHitches = 4
var flux = 1.0
var audioDone = false

@onready var stateLockoutTimer = $stateLockoutTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	breathState = BREATH.IDLE
	sneezeState = SNEEZE.IDLE
	nextRandSneeze(Time.get_ticks_msec())
	var root = get_parent().get_tree().root
	Globals.randSneezeButton.connect("pressed",randSneezeNow)
	pass # Replace with function body.

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
		
	if(Globals.SNEEZE['value'] < Globals.getHitchLimit() or Globals.lungCurrent < Globals.lungCapacity * Globals.lungMinThreshold):
		fit_flag = false
		
	if(oxygen >= oxygenLimit/2):
		recovering = false
	oxygen -= delta
	
	for comp : TickleComponent in tickleComponents:
		Globals.addSneezeValue(delta * comp.get_tickle())
	
	for comp : IrritationComponent in irritationComponents:
		Globals.addIrritation(delta * comp.get_irritation())

	var irritationDelta = Globals.irritationInfluence * Globals.getIrritationPercent() * delta
	Globals.addSneezeValue(irritationDelta)
	
	calcNoseRedness()
	
	randSneeze(delta)
	Globals.sensitivity += Globals.getIrritationPercent() * delta * 5.0/60
	
	Globals.adjustSneezeSize(Globals.SNEEZESIZE['average'] - (Globals.SNEEZESIZE['controlledAverage'] * Globals.CONTROL['value']),delta,Globals.sneezeSizePassiveRate)
	#print(Globals.calcSneezeSize())
	#print(sensitivity)
	#print("Oxygen: "+str(oxygen))
	#print("SneezeState: " +str(sneezeState))
	#print("BreathState: " +str(breathState))
	#print("Repeat Hitches: "+str(repeat_hitches))
	if(stateLockoutTimer.is_stopped()):
		match(sneezeState):
			SNEEZE.IDLE:
				Globals.regenFire(delta)
				Globals.regenControl(delta)
				if(Globals.SNEEZE['value'] >= Globals.getTickleLimit()):
					go_tickle()
				
			SNEEZE.TICKLE:
				tickle.emit(Globals.getTicklePercent())
				if(Globals.SNEEZE['value'] >= Globals.getHitchLimit() and not breakHitch()):
					go_hitch(false)
					
				elif(Globals.SNEEZE['value'] < Globals.getTickleLimit() - 10):
					go_idle()
					
			SNEEZE.HITCH:
				#if(canSneeze(fit_flag)):
				#	go_sneeze(false)

				if(Globals.SNEEZE['value'] < Globals.getHitchLimit() - 10):
					go_tickle()
					
			SNEEZE.WAIT:
				if(canSneeze(fit_flag)):
					print("Sneeze wait triggered sneeze")
					breathState = BREATH.IDLE
					go_sneeze(false)
				
				elif(Globals.SNEEZE['value'] < Globals.getHitchLimit() - 10):
					print("Sneeze wait to idle")
					breathState = BREATH.IDLE
					go_tickle()
					
				elif(repeat_hitches == true and canHitch()):
					print("Sneeze wait triggered hitch")
					go_hitch(false)
					
				elif(breakHitch()):
					print("break hitch!")
					recovering = true
					breathState = BREATH.IDLE
					Globals.sensitivity = Globals.sensitivity * 1.5
					stateLockoutTimer.wait_time = 2.5
					stateLockoutTimer.start()
					go_tickle()

				elif(canHitch() and Globals.lungCurrent < Globals.lungIdleThreshold or Globals.SNEEZE['value'] >= Globals.SNEEZE['max']):
					repeat_hitches = true
					print("Idle Hitching....")
				
				else:
					repeat_hitches = false
				
				
			SNEEZE.SNEEZE:					
				pass
					
				
	
	
	oxygen = clamp(oxygen,-oxygenLimit,oxygenLimit)
	handleBreath(delta)
	noseTrails()
	
	Globals.decaySneezeValue(delta,false)
	Globals.decayIrritationValue(delta,false)

func nextRandSneeze(time):
	randSneezeTime = time + (randf_range(15, 180 - (Globals.getColdPercent() * 120)) * 1000)
	randSneezeDuration = randf_range(2,8) * 1000
	randSneezeAmount = randf_range(0.5,3) * Globals.SNEEZE['max']
	randSneezeAmount = lerpf(randSneezeAmount,randSneezeAmount/3,Globals.getColdPercent())
	print(randSneezeAmount)
	print(randSneezeDuration)

func randSneezeNow():
	randSneezeTime = Time.get_ticks_msec()
	
func randSneeze(delta):
	var now = Time.get_ticks_msec()
	if now >= randSneezeTime:
		var sneezeDelta = (randSneezeAmount / randSneezeDuration) / delta
		Globals.addSneezeValue(sneezeDelta)
	if now >= randSneezeDuration + randSneezeTime:
		nextRandSneeze(now)
	
func go_idle():
	fit_flag = false
	numHitches = 0
	#fit_flag = false
	idle.emit()
	sneezeState = SNEEZE.IDLE
	
func go_tickle():
	print("Go Tickle")
	fit_flag = false
	numHitches = 0
	#fit_flag = false
	tickle.emit(Globals.getTicklePercent())
	sneezeState = SNEEZE.TICKLE

func go_hitch(wait: bool):
	print("Go hitch ",wait)
	stateLockoutTimer.wait_time = 0.5
	stateLockoutTimer.start()
	fit_flag = false
	if(wait):
		nextValidHitchTime = Time.get_ticks_msec() + (randf_range(0.5,1.0)*hitchCooldown)
		hitch.emit(true)
		sneezeState = SNEEZE.WAIT
		breathState = BREATH.WAIT
	else:
		if(Time.get_ticks_msec() < nextValidHitchTime):
			return
		#print("Hitch?")
		#print(Globals.sneezeValue)
		hitchMult = randf_range(0.25,1.0)
		hitch.emit(false)
		numHitches += 1
		sneezeState = SNEEZE.HITCH
		breathState = BREATH.HITCH

func go_sneeze(wait: bool):
	print("go_sneeze ", wait)
	numHitches = 0
	stateLockoutTimer.wait_time = 1.0
	stateLockoutTimer.start()
	repeat_hitches = false
	if(wait):
		#fit_flag = false
		sneezeState = SNEEZE.WAIT
		breathState = BREATH.IDLE
	else:
		fit_flag = true
		print("Emitting sneeze signal")
		sneeze.emit(Globals.SNEEZESIZE['value'])
		sneezeState = SNEEZE.SNEEZE
		
	
func canSneeze(isFit: bool):
	#print("recovering: ",recovering, " Sneeze Value/Limit", Globals.sneezeValue, Globals.getSneezeLimit(isFit), " Lungs Ready ", Globals.lungSneezeReady(isFit))
	return not recovering and Globals.SNEEZE['value'] >= Globals.getSneezeLimit(isFit) and Globals.lungSneezeReady(isFit)

func canHitch():
	return Globals.SNEEZE['value'] >= Globals.getHitchLimit() and Globals.lungCurrent < Globals.lungCapacity and numHitches <= maxHitches
	
func breakHitch():
	return recovering or oxygen <= -oxygenLimit * 0.1 or numHitches > maxHitches
	
func needToBreathe():
	return oxygen <= 0



func breathe(delta,speed,target):
	if(speed > 0):
		if(not Globals.canBreatheIn() or Globals.lungCurrent >= Globals.lungCapacity * target):
			return false
	else:
		if(not Globals.canBreatheOut() or Globals.lungCurrent <= Globals.lungCapacity * target):
			return false
	
	var amount = speed * delta
	if(amount > 0):
		oxygen += oxygenPerBreath * amount
	
	for i in range (0, particleArray.size()):
		particleArray[i].breathe(get_nose_position(), to_global(breathVector*100), speed * Globals.breathSpeedMultiplier, delta)
			
	Globals.lungCurrent += amount
	
	return true
	
func noseTrails():
	smokeBreathe.emit(breathState == BREATH.OUT and Globals.CONTROL['value'] < Globals.CONTROL['max'] * Globals.CONTROL['smokeThreshold'])
	smoke.emit((breathState == BREATH.IDLE or breathState == BREATH.WAIT) and Globals.CONTROL['value'] < Globals.CONTROL['max'] * Globals.CONTROL['smokeTrailThreshold'] and stateLockoutTimer.is_stopped())
	noseFire.emit(breathState == BREATH.SNEEZE and Globals.CONTROL['value'] < Globals.CONTROL['max'] * Globals.CONTROL['fireThreshold'])


func handleBreath(delta):
	match(breathState):
		BREATH.IDLE:
			flareNose.emit(false)
			if(needToBreathe()):
				if(Globals.canBreatheIn()):
					breathState = BREATH.IN
				else:
					breathState = BREATH.OUT
			elif(Globals.canBreatheOut()):
				breathState = BREATH.OUT
		
		BREATH.IN:
			flareNose.emit(true)
			if(not breathe(delta,breathState,Globals.lungIdleThreshold)):
				breathState = BREATH.OUT
			
		BREATH.OUT:
			flareNose.emit(false)
			if(not breathe(delta,breathState,0)):
				breathState = BREATH.IDLE
		
		BREATH.SNEEZE:
			#print("Sneezing?")
			flareNose.emit(true)
			if(not breathe(delta,breathState * Globals.SNEEZESIZE['value'] * Globals.sneezeSizeDecayRate,0)):
				breathState = BREATH.IDLE
			else:
				Globals.decayControl(delta)
				Globals.particleSneezeDecay(delta)
				Globals.decaySneezeValue(delta,true)
				Globals.decayIrritationValue(delta,true)
				Globals.adjustSneezeSize(Globals.SNEEZESIZE['min'],delta,Globals.sneezeSizeDecayRate)
				fire.emit(Globals.useFire(delta))
				Globals.doSneeze(delta)
				sprayAmount.emit(Globals.getMessPercent() * Globals.SNEEZESIZE['value'])
				Globals.sensitivity -= 2 * Globals.SNEEZESIZE['value'] * delta
		
		BREATH.HITCH:
			breathe(delta,breathState*hitchMult/Globals.hitchiness,Globals.lungCapacity)
			Globals.adjustSneezeSize(Globals.SNEEZESIZE['max'],delta,Globals.sneezeSizeErrRate)
			if(Globals.lungCurrent >= Globals.lungCapacity * Globals.lungThreshold):
				repeat_hitches = false
			
		BREATH.WAIT:
			breathe(delta,breathState,0)

func calcNoseRedness():
	var irrLight = 0.33 * Globals.irritationValue / Globals.irritationMax
	var allergyLight = 0.33 * Globals.allergyValue / Globals.allergyMax
	var coldLight = 0.33 * Globals.coldIntensity / Globals.coldMax
	redLight.modulate = Color(.7,0.05,0.05,irrLight + allergyLight + coldLight)
	
func anim_wait():
	breathState = BREATH.WAIT
	
func anim_hitch():
	breathState = BREATH.HITCH
	
func anim_sneeze():
	breathState = BREATH.SNEEZE

signal idle()
signal tickle(val: float)
signal hitch(waiting: bool)
signal sneeze(power: float)
signal flareNose(val: bool)
signal fire(val:float)
signal smoke(val: bool)
signal smokeBreathe(val: bool)
signal noseFire(val:bool)
signal sprayAmount(val:float)

func _on_audio_engine_audio_done(wasSneeze: bool):
	breathState = BREATH.IDLE
	print("Audio Done, was sneeze: ",wasSneeze)
	print(Globals.SNEEZE['value'])
	print(Globals.getSneezeLimit(wasSneeze))
	
	if(canSneeze(wasSneeze)):
		go_sneeze(false)
	elif(Globals.SNEEZE['value'] >= Globals.getHitchLimit() - 10):
		go_hitch(!wasSneeze)
	elif(Globals.SNEEZE['value'] >= Globals.getTickleLimit() - 10):
		go_tickle()
	else:
		go_idle()
		
			
			
		
func get_nose_position():
	return $"../Skeleton2D/LowerNeckRootBone2D/UpperNeckRootBone2D/HeadRootBone2D/ParticleDetector".global_position
	
##Manage Particles
func _on_particle_detector_area_entered(area):
	particleArray.append(area.get_parent())

func _on_particle_detector_area_exited(area):
	var i = particleArray.find(area.get_parent())
	particleArray.remove_at(i)


func _on_nose_hitbox_area_entered(area):
	if(area is TickleComponent):
		tickleComponents.append(area)
		
	if(area is IrritationComponent):
		irritationComponents.append(area)

func _on_nose_hitbox_area_exited(area):
	if(area is TickleComponent):
		var index = tickleComponents.find(area)
		tickleComponents.remove_at(index)
		
	if(area is IrritationComponent):
		var index = irritationComponents.find(area)
		irritationComponents.remove_at(index)
