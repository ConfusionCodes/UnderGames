extends Node

const MIN_DISTANCE: float = 250;

@onready var swipe_delay: Timer = $SwipeDelay
var press_location: Vector2 = Vector2.ZERO;
var current_action: String = "";

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		var distance = press_location.distance_squared_to(event.position);
		if distance > MIN_DISTANCE * MIN_DISTANCE:
			calculate_angle(press_location.direction_to(event.position));
		return
	if event is not InputEventScreenTouch: return
	var touch_event: InputEventScreenTouch = event;
	if touch_event.is_pressed():
		press_location = touch_event.position;
		return
	if touch_event.is_released():
		if current_action == "":
			pass
		else:
			Input.action_release(current_action);
			current_action = "";

func calculate_angle(direction: Vector2) -> void:
	if current_action != "": return;
	var abs_direction: Vector2 = direction.abs();
	if abs_direction.x > abs_direction.y:
		current_action = "right" if direction.x > 0 else "left";
	else:
		current_action = "down" if direction.y > 0 else "up";
	Input.action_press(current_action);
	
	
