extends Panel
class_name LevelSelect

const LEVEL_DIR: String = "res://levels/campaign/";

@onready var level_grid: GridContainer = $Margins/LevelGrid

func _ready() -> void:
	for file: String in ResourceLoader.list_directory(LEVEL_DIR):
		var button := Button.new();
		button.text = file.get_file().get_slice(".", 0);
		button.custom_minimum_size = Vector2(128, 128);
		button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER | Control.SIZE_EXPAND;
		button.add_theme_font_size_override("font_size", 64);
		button.pressed.connect(_enter_level.bind(LEVEL_DIR + file))
		level_grid.add_child(button);

func _enter_level(path: String) -> void:
	SceneManager.enter_level(path);

func _enter_home_menu() -> void:
	SceneManager.enter_menu();
