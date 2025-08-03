extends Sprite2D
class_name Enemy

const LEFT_WING_POS = Vector2(-288, 512);
const RIGHT_WING_POS = Vector2(288, 512);

@onready var left_wing: Sprite2D = $LeftWing
@onready var right_wing: Sprite2D = $RightWing
@onready var hit_sfx: AudioStreamPlayer = $HitSfx
@onready var explode_sfx: AudioStreamPlayer = $ExplodeSfx
@onready var explode_timer: Timer = $ExplodeTimer

@export var hit_sound: AudioStream;

func reset() -> void:
	
	left_wing.visible = false;
	left_wing.position = LEFT_WING_POS;
	left_wing.rotation = 0;
	left_wing.modulate = Color.WHITE;
	right_wing.visible = false;
	right_wing.position = RIGHT_WING_POS;
	right_wing.rotation = 0;
	right_wing.modulate = Color.WHITE;
	
	self.self_modulate = Color.WHITE;
	

func _on_hitbox_entered(area: Area2D) -> void:
	area.get_parent().queue_free();
	self.self_modulate = Color.TRANSPARENT;
	left_wing.visible = true;
	right_wing.visible = true;
	hit_sfx.play();
	explode_timer.start();
	await explode_timer.timeout
	explode_sfx.play();
	var tween = get_tree().create_tween().set_parallel(true);
	tween.tween_property(left_wing, "position", Vector2(-128, 256), 0.5).as_relative();
	tween.tween_property(left_wing, "rotation", -PI/2, 0.5);
	tween.tween_property(left_wing, "modulate", Color.TRANSPARENT, 0.5);
	tween.tween_property(right_wing, "position", Vector2(128, 256), 0.5).as_relative();
	tween.tween_property(right_wing, "rotation", PI/2, 0.5);
	tween.tween_property(right_wing, "modulate", Color.TRANSPARENT, 0.5);
	
