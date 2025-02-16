extends AudioStreamPlayer2D
class_name AudioDirectoryRandomizer

@export_dir var load_audio_directory : String

func _ready() -> void:
	print("AudioLoader Initialized.")
	if DirAccess.dir_exists_absolute(load_audio_directory):
		print("Loading audio from ",load_audio_directory)
		
		if stream == null:
			print("Creating randomizer.")
			stream = AudioStreamRandomizer.new()
		
		print("Adding new streams....")
		
		var loader := AudioLoader.new()
		
		for file : String in DirAccess.get_files_at(load_audio_directory):
			if file.ends_with(".wav"):
				var filepath = load_audio_directory + "/" + file
				var new_stream : AudioStreamWAV = loader.loadfile(filepath)
				new_stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
				stream.add_stream(-1, new_stream, 1.0)
