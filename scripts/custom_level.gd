extends HBoxContainer
class_name CustomLevelButton

@onready var title_edit: LineEdit = %TitleEdit
@onready var title_label: Label = %TitleLabel
@onready var rename_button: Button = %RenameButton

signal level_edited(index: int);
signal level_deleted(index: int);
signal level_renamed(index: int);

static func create(title: String, index: int) -> void:
	var button := CustomLevelButton.new()
	button.set_title(title);

var title: String;
var index: int;

func set_title(title: String) -> void:
	title = title;
	title_label.text = title;
	title_edit.text = title;


func _on_rename_button_pressed() -> void:
	title_label.visible = false;
	title_edit.visible = true;
	rename_button.disabled = true;


func _on_title_text_submitted(new_text: String) -> void:
	set_title(new_text);
	title_edit.visible = false;
	title_label.visible = true;
	rename_button.disabled = false;
	level_renamed.emit(index);


func _on_delete_button_pressed() -> void:
	level_deleted.emit(index);


func _on_edit_button_pressed() -> void:
	level_edited.emit(index);
