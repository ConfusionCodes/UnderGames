extends Node

var main_menu_scene: PackedScene = preload("res://scenes/main_menu.tscn");
var level_select_scene: PackedScene = preload("res://scenes/level_select.tscn");
var board_scene: PackedScene = preload("res://scenes/board.tscn");

@export var current_level: ShooterLevel = null;

func enter_menu() -> void:
	get_tree().change_scene_to_packed(main_menu_scene);

func enter_level_select() -> void:
	get_tree().change_scene_to_packed(level_select_scene);

func enter_level(path: String) -> void:
	current_level = ResourceLoader.load(path);
	get_tree().change_scene_to_packed(board_scene);
