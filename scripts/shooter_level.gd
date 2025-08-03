extends Resource
class_name ShooterLevel

const TILE_TYPES: int = 2;
const MAX_BULLETS: int = 10;

@export var size: int;
@export var bullets: int;
@export var tiles: PackedByteArray;
@export_multiline var notification: String;
@export var custom: bool;

static func default_custom() -> ShooterLevel:
	var level := ShooterLevel.new();
	level.size = 3;
	level.bullets = 1;
	level.tiles = [0, 0, 0, 0, 0, 0, 0, 0, 0];
	level.notification = "";
	level.custom = true;
	return level;

func size_squared() -> int:
	return size * size;
