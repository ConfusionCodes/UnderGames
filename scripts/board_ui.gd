extends PanelContainer
class_name BoardUi

@onready var board: Board = $".."
@onready var menu_button: Button = $"../MenuButton"
@onready var reset_button: Button = $"../ResetButton"

var is_open: bool = true;

func open(value: bool) -> void:
	is_open = value;
	menu_button.disabled = value;
	reset_button.disabled = value;
	self.visible = value;


func _on_menu_button_pressed() -> void:
	self.open(true);


func _on_reset_button_pressed() -> void:
	board.load_level(board.level);


func _on_back_button_pressed() -> void:
	self.open(false);


func _on_restart_button_pressed() -> void:
	_on_reset_button_pressed();
	_on_back_button_pressed();


func _on_level_select_button_pressed() -> void:
	SceneManager.enter_level_select();


func _on_main_menu_button_pressed() -> void:
	SceneManager.enter_menu();
