@tool
extends AudioStreamPlayer2D
class_name AudioDirectoryRandomizer

@export_dir var load_audio_directory : String
@export var do_filter : bool = false
@export var file_filter : String = ""
@export_tool_button("Load Directory") var load_func = do_load

func _ready() -> void:
	print("AudioLoader Initialized.")
	do_load()

func do_load():
	stream = null
	if DirAccess.dir_exists_absolute(load_audio_directory):
		print("Loading audio from ",load_audio_directory)
		
		if stream == null:
			print("Creating randomizer.")
			stream = AudioStreamRandomizer.new()
		
		print("Adding new streams....")
		
		var files_list = get_all_files(load_audio_directory)
		
		for file : String in files_list:
			#print("File : ",file)
			if file.ends_with(".wav.import"):
				#print("Checking file ",file)
				if do_filter:
					if not file.contains(file_filter):
						#print("File ",file," did not contain ",file_filter)
						continue
				
				file = file.split(".import")[0]
				print("Importing file %s"%file)
				var new_stream = load(file)
				new_stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
				stream.add_stream(-1, new_stream, 1.0)
					

func get_all_files(path: String, file_ext := "", files := []):
	var dir = DirAccess.open(path)
	if dir != null:
		dir.list_dir_begin()

		var file_name = dir.get_next()

		while file_name != "":
			if dir.current_is_dir():
				files = get_all_files(dir.get_current_dir().path_join(file_name), file_ext, files)
			else:
				if file_ext and file_name.get_extension() != file_ext:
					file_name = dir.get_next()
					continue

				files.append(dir.get_current_dir().path_join(file_name))

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access %s." % path)

	return files
