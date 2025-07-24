extends Node2D
class_name VoiceBox

@export var brain : Brain

@export var Buildup : AudioStreamPlayer2D = null;
@export var Hitch : AudioStreamPlayer2D = null;
@export var Sigh : AudioStreamPlayer2D = null;
@export var SneezeNormal : AudioStreamPlayer2D = null;
@export var SneezeBig : AudioStreamPlayer2D = null;
@export var SneezeStifle : AudioStreamPlayer2D = null;
@export var Sniff : AudioStreamPlayer2D = null;
@export var Spray : AudioStreamPlayer2D = null;

signal on_buildup_finished()
signal on_hitch_finished()
signal on_sigh_finished()
signal on_sneeze_finished()
signal on_sniff_finished()
signal on_spray_finished()

signal on_sneeze()
signal on_hitch()
signal on_buildup()
signal on_sigh()
signal on_sniff()
signal on_spray()

@export_category("Audio Settings")
@export var pitch_range : Vector2 = Vector2(1,1)

func _ready():
	if Buildup != null:
		Buildup.finished.connect(on_buildup_finished.emit);
	if Hitch != null: 
		Hitch.finished.connect(on_hitch_finished.emit);
	if Sigh != null: 
		Sigh.finished.connect(on_sigh_finished.emit);
	if SneezeNormal != null: 
		SneezeNormal.finished.connect(on_sneeze_finished.emit);
	if SneezeBig != null: 
		SneezeBig.finished.connect(on_sneeze_finished.emit);
	if SneezeStifle != null: 
		SneezeStifle.finished.connect(on_sneeze_finished.emit);
	if Sniff != null: 
		Sniff.finished.connect(on_sniff_finished.emit);
	if Spray != null:
		Spray.finished.connect(on_spray_finished.emit);

##Randomizes pitch based on the Pitch Range variable.
func randomize_pitch(player : AudioStreamPlayer2D):
	player.pitch_scale = randf_range(pitch_range.x,pitch_range.y)
	
func Play_Buildup():
	if Buildup: #If sound samples exist, play them.
		if not Buildup.playing:
			randomize_pitch(Buildup)
			Buildup.play();
			on_buildup.emit()
	else: #Can't play sound samples, skip the playback and go to the finished event.
		on_buildup_finished.emit()


func Play_Hitch():
	if Hitch:
		if not Hitch.playing:
			randomize_pitch(Hitch)
			Hitch.play();
			on_hitch.emit()
	else:
		on_hitch_finished.emit()


func Play_Sigh():
	if Sigh:
		if not Sigh.playing:
			randomize_pitch(Sigh)
			Sigh.play();
			on_sigh.emit()
	else:
		on_sigh_finished.emit()

func Play_Sneeze():
	if brain.sneeze_size >= 0.8:
		if SneezeBig:
			if not SneezeBig.playing:
				randomize_pitch(SneezeBig)
				SneezeBig.play();
				on_sneeze.emit()
				return
	elif brain.sneeze_size >= 0.3:
		if SneezeNormal:
			if not SneezeNormal.playing:
				randomize_pitch(SneezeNormal)
				SneezeNormal.play();
				on_sneeze.emit()
				return
	else:
		if SneezeStifle:
			if not SneezeStifle.playing:
				randomize_pitch(SneezeStifle)
				SneezeStifle.play();
				on_sneeze.emit()
				return
	
	on_sneeze_finished.emit()


func Play_Sniff():
	if Sniff:
		if not Sniff.playing:
			randomize_pitch(Sniff)
			Sniff.play();
			on_sniff.emit()
	else:
		on_sniff_finished.emit()


func Play_Spray():
	if Spray:
		if not Spray.playing:
			randomize_pitch(Spray)
			Spray.play();
			on_spray.emit()
	else:
		on_spray_finished.emit()
