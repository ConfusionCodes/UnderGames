extends Sprite2D
class_name Bullet

const SPEED = 512.0 * 8;

func _process(delta: float) -> void:
	position.y -= SPEED * delta;
