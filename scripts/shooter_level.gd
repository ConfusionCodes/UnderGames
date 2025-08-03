extends Resource
class_name ShooterLevel

const TILE_TYPES: int = 2;
const MAX_BULLETS: int =  10;

@export var size: int;
@export var bullets: int;
@export var tiles: PackedByteArray;
@export_multiline var notification: String;
@export var custom: bool;

func size_squared() -> int:
	return size * size;
