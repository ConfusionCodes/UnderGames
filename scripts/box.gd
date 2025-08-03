extends Tile
class_name Box

@onready var hitbox: Area2D = $Hitbox
@onready var hit_sfx: AudioStreamPlayer = $HitSfx

func _on_hitbox_entered(area: Area2D) -> void:
	self.destroy();
	hit_sfx.play();
	area.get_parent().queue_free();

func destroy() -> void:
	hitbox.queue_free();
	var tween = get_tree().create_tween().set_parallel(true);
	tween.tween_property(self, "rotation", PI/2, 0.5);
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5);
	tween.tween_property(self, "scale", self.scale * 1.5, 0.5);
	await tween.finished;
	self.queue_free();
