extends Node2D
class_name VoiceBox

@export var Buildup : AudioStreamPlayer2D = null;
@export var Hitch : AudioStreamPlayer2D = null;
@export var Sigh : AudioStreamPlayer2D = null;
@export var Sneeze : AudioStreamPlayer2D = null;
@export var Sniff : AudioStreamPlayer2D = null;
@export var Spray : AudioStreamPlayer2D = null;

signal buildup_finished
signal hitch_finished
signal sigh_finished
signal sneeze_finished
signal sniff_finished
signal spray_finished

signal on_sneeze
signal on_hitch
signal on_buildup
signal on_sigh
signal on_sniff
signal on_spray

func _ready():
	if Buildup: Buildup.finished.connect(buildup_finished.emit);
	if Hitch: Hitch.finished.connect(hitch_finished.emit);
	if Sigh: Sigh.finished.connect(sigh_finished.emit);
	if Sneeze: Sneeze.finished.connect(sneeze_finished.emit);
	if Sniff: Sniff.finished.connect(sniff_finished.emit);
	if Spray: Spray.finished.connect(spray_finished.emit);
	
func Play_Buildup():
	if Buildup: #If sound samples exist, play them.
		if not Buildup.playing:
			Buildup.play();
			on_buildup.emit()
	else: #Can't play sound samples, skip the playback and go to the finished event.
		buildup_finished.emit()


func Play_Hitch():
	if Hitch:
		if not Hitch.playing:
			Hitch.play();
			on_hitch.emit()
	else:
		hitch_finished.emit()


func Play_Sigh():
	if Sigh:
		if not Sigh.playing:
			Sigh.play();
			on_sigh.emit()
	else:
		sigh_finished.emit()


func Play_Sneeze():
	if Sneeze:
		if not Sneeze.playing:
			Sneeze.play();
			on_sneeze.emit()
	else:
		sneeze_finished.emit()
	

func Play_Sniff():
	if Sniff:
		if not Sniff.playing:
			Sniff.play();
			on_sniff.emit()
	else:
		sniff_finished.emit()


func Play_Spray():
	if Spray:
		if not Spray.playing:
			Spray.play();
			on_spray.emit()
	else:
		spray_finished.emit()
