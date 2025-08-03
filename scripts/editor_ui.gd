extends PanelContainer
class_name EditorUi

@onready var editor: LevelEditor = $".."

var is_open: bool = false;

func open(value: bool) -> void:
	is_open = value;
	self.visible = value;
	%BulletButton.disabled = value;
	%SaveButton.disabled = value;
	%MenuButton.disabled = value;


func _on_menu_button_pressed() -> void:
	open(true);


func _on_back_button_pressed() -> void:
	open(false);


func _on_play_button_pressed() -> void:
	editor.save();
	SceneManager.enter_level(editor.path);


func _on_level_select_button_pressed() -> void:
	SceneManager.enter_level_select();
