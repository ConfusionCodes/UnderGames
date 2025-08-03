extends Node

const MAIN_MENU: PackedScene = preload("res://scenes/main_menu.tscn");
const LEVEL_SELECT: PackedScene = preload("res://scenes/level_select.tscn");
const CUSTOM_LEVEL_SELECT: PackedScene = preload("res://scenes/custom_level_select.tscn");
const BOARD: PackedScene = preload("res://scenes/board.tscn");
const LEVEL_EDITOR = preload("res://scenes/level_editor.tscn");

@export var current_level: ShooterLevel = null;
@export var current_path: String = "";

func enter_menu() -> void:
	current_level = null;
	current_path = "";
	get_tree().change_scene_to_packed(MAIN_MENU);

func enter_level_select() -> void:
	current_level = null;
	current_path = "";
	get_tree().change_scene_to_packed(LEVEL_SELECT);

func enter_custom_level_select() -> void:
	current_level = null;
	current_path = "";
	get_tree().change_scene_to_packed(CUSTOM_LEVEL_SELECT);

func enter_level(path: String) -> void:
	current_level = ResourceLoader.load(path);
	current_path = path;
	get_tree().change_scene_to_packed(BOARD);
	
func enter_editor(path: String) -> void:
	current_level = ResourceLoader.load(path);
	current_path = path;
	get_tree().change_scene_to_packed(LEVEL_EDITOR);
	
	
	
