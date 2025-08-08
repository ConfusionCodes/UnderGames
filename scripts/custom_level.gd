extends PanelContainer
class_name CustomLevelButton

const SCENE = preload("res://scenes/custom_level.tscn");

@onready var title_edit: LineEdit = %TitleEdit

signal level_edited(id: int);
signal level_deleted(id: int);
signal level_renamed(id: int);

static func create(title: String, id: int) -> CustomLevelButton:
	var button: CustomLevelButton = SCENE.instantiate();
	button.set_title(title);
	button.id = id;
	return button;

var title: String;
var id: int;

func set_title(title: String) -> void:
	title = title.validate_filename();
	self.title = title;
	%TitleEdit.text = title;


func _on_title_text_submitted(new_text: String) -> void:
	set_title(new_text);
	level_renamed.emit(id);

func _on_title_edit_focus_exited() -> void:
	_on_title_text_submitted(title_edit.text);

func _on_delete_button_pressed() -> void:
	level_deleted.emit(id);

func _on_edit_button_pressed() -> void:
	level_edited.emit(id);
