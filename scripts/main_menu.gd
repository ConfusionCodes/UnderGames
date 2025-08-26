extends Control
class_name MainMenu


func _on_button_pressed() -> void:
	SceneManager.enter_level(LevelSelect.LEVEL_DIR + "1.tres")
