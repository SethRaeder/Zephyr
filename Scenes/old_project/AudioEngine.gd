extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var wasPlaying = false
var wasSneeze = false
var fireOn = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!audioPlaying() and wasPlaying):
		audioDone.emit(wasSneeze)
		wasPlaying = false
		wasSneeze = false
		$"../Skeleton2D/LowerNeckRootBone2D/UpperNeckRootBone2D/HeadRootBone2D/ParticleManager".spray(false)
		$"../Skeleton2D/LowerNeckRootBone2D/UpperNeckRootBone2D/HeadRootBone2D/ParticleManager".fire(false)

func audioPlaying():
	return $NormalSneeze.playing or $Hitch.playing or $BigSneeze.playing or $StifleSneeze.playing
	
signal audioDone(wasSneeze: bool)

func sneeze():
	print("Audio Engine => Trying to play audio for sneeze size ",Globals.SNEEZE['value'])
	wasSneeze = true
	
	if Globals.SNEEZE['value'] >= 0.8:
		bigSneeze()
	elif Globals.SNEEZE['value'] >= 0.3:
		normalSneeze()
	else:
		stifleSneeze()
		
func normalSneeze():
	wasPlaying = true
	stopAudio()
	$NormalSneeze.play(0.3)
	
func hitch():
	wasSneeze = false
	wasPlaying = true
	stopAudio()
	$Hitch.play()
	
func bigSneeze():
	wasPlaying = true
	stopAudio()
	$BigSneeze.play(0.3)
	
func stifleSneeze():
	wasPlaying = true
	stopAudio()
	$StifleSneeze.play(0.3)

func stopAudio():
	$NormalSneeze.stop()
	$Hitch.stop()
	$BigSneeze.stop()
	$StifleSneeze.stop()

func _on_sneeze_manager_fire(val):
	if(!fireOn and val > 0):
		fireOn = true
		$FirePlayer.volume_db = lerpf(-15, -3, val);
		$FirePlayer.play()

func _on_fire_player_finished():
	fireOn = false
