extends Node

const MIN_DISTANCE: float = 500;

@onready var swipe_delay: Timer = $SwipeDelay
var current_action: String = "";

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		var drag_event: InputEventScreenDrag = event;
		var velocity = drag_event.screen_velocity;
		var direction = drag_event.screen_relative;
		if velocity.length() < MIN_DISTANCE: return;
		calculate_angle(direction);
	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event;
		if touch_event.is_released() and current_action != "":
			Input.action_release(current_action);
			current_action = "";

func calculate_angle(direction: Vector2):
	if current_action != "": return;
	var abs_direction = direction.abs();
	if abs_direction.x > abs_direction.y:
		if direction.x > 0:
			current_action = "right";
		else:
			current_action = "left";
	else:
		if direction.y > 0:
			current_action = "down";
		else:
			current_action = "up";
	Input.action_press(current_action);
	
	
