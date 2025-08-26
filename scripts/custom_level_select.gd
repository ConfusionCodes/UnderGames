extends Panel
class_name CustomLevelSelect

const CUSTOM_LEVEL_DIR: String = "user://levels/";

@onready var level_container: VBoxContainer = %LevelContainer
@onready var name_input_panel: PanelContainer = %NameInputPanel
@onready var name_edit: LineEdit = %NameEdit
@onready var error_label: Label = %ErrorLabel

var level_paths: PackedStringArray = [];
var levels: Array[CustomLevelButton] = [] :
	get():
		var levels: Array[CustomLevelButton] = [];
		for child in level_container.get_children():
			if child is CustomLevelButton:
				levels.append(child as CustomLevelButton);
		return levels;

func _ready() -> void:
	if !DirAccess.dir_exists_absolute(CUSTOM_LEVEL_DIR):
		DirAccess.make_dir_absolute(CUSTOM_LEVEL_DIR);
	var used_ids: Array[int] = [];
	level_paths = ResourceLoader.list_directory(CUSTOM_LEVEL_DIR);
	for file: String in level_paths:
		var id: int = randi();
		while used_ids.has(id):
			id = randi();
		var button := CustomLevelButton.create(file.get_basename(), id);
		button.level_edited.connect(_edit_level);
		button.level_renamed.connect(_rename_level);
		button.level_deleted.connect(_delete_level);
		level_container.add_child(button)
		

func id_to_index(id: int) -> int:
	@warning_ignore("untyped_declaration")
	var index: int = level_container.get_children().find_custom(func(level): return level.id == id);
	return index;

func _on_home_button_pressed() -> void:
	SceneManager.enter_level_select();


func _on_new_button_pressed() -> void:
	name_input_panel.visible = true;


func _on_cancel_button_pressed() -> void:
	name_input_panel.visible = false;
	name_edit.text = "";


func _on_create_button_pressed() -> void:
	var level: ShooterLevel = ShooterLevel.default_custom();
	var path := CUSTOM_LEVEL_DIR.path_join(name_edit.text + ".tres");
	var error := ResourceSaver.save(level, path);
	if error != Error.OK:
		error_label.visible = true;
		error_label.text = error_label.text.format(error);
	else:
		SceneManager.enter_editor(path);


func _edit_level(id: int) -> void:
	var index: int = id_to_index(id);
	if index == -1: return;
	SceneManager.enter_editor(CUSTOM_LEVEL_DIR.path_join(level_paths[index]));


func _rename_level(id: int) -> void:
	var index: int = id_to_index(id);
	if index == -1: return;
	var path: String = CUSTOM_LEVEL_DIR.path_join(level_paths[index]);
	var directory: String = path.get_base_dir();
	var new_name = levels[index].title;
	var error: Error = DirAccess.open(directory).rename(path.get_file(), new_name + ".tres");
	print("Error: %s" % error);
	print("Path: %s" % path);
	print("New Name: %s" % new_name);


func _delete_level(id: int) -> void:
	var index: int = id_to_index(id);
	if index == -1: return;
	var dir_access := DirAccess.open(CUSTOM_LEVEL_DIR);
	dir_access.remove(level_paths[index]);
	levels[index].queue_free();
