extends Panel
class_name CustomLevelSelect

const CUSTOM_LEVEL_DIR: String = "user://levels/"

func _ready() -> void:
	if !DirAccess.dir_exists_absolute(CUSTOM_LEVEL_DIR):
		DirAccess.make_dir_absolute(CUSTOM_LEVEL_DIR);
	for file: String in ResourceLoader.list_directory(CUSTOM_LEVEL_DIR):
		
		
