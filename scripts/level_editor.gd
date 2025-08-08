extends Node2D
class_name LevelEditor

const SCREEN_WIDTH: float = 720.0;
const SCREEN_HEIGHT: float = 1280.0;
const DEBUG_LEVEL: String = "res://levels/debug.tres";

@export var WALL_TEXTURE: Texture2D;
@export var BOX_TEXTURE: Texture2D;
@export var BULLET_INDICATOR_SCENE: PackedScene;

@onready var tile_grid: GridContainer = $Playfield/TileGrid
@onready var playfield: NinePatchRect = $Playfield
@onready var enemy: Sprite2D = $Enemy
@onready var player: Sprite2D = $Player
@onready var save_button: Button = %SaveButton
@onready var menu_button: Button = %MenuButton
@onready var error_label: Label = $Playfield/ErrorLabel
@onready var bullet_button: Button = %BulletButton
@onready var bullets: Node2D = $Bullets
@onready var grid_size_down_button: Button = %GridSizeDownButton
@onready var grid_size_up_button: Button = %GridSizeUpButton
@onready var grid_size_container: MarginContainer = %GridSizeContainer

var path: String;
var level: ShooterLevel;

func _ready() -> void:
	path = SceneManager.current_path;
	level = SceneManager.current_level;
	if !level or path.is_empty():
		path = DEBUG_LEVEL;
		level = preload(DEBUG_LEVEL);
		
	layout()

func layout() -> void:
	tile_grid.columns = level.size
	var new_tiles: bool = false;
	if tile_grid.get_child_count() != level.size_squared():
		for child in tile_grid.get_children():
			child.queue_free();
		new_tiles = true;
	for i in level.size_squared():
		var fake_tile: TextureButton;
		if new_tiles:
			fake_tile = TextureButton.new();
			fake_tile.size_flags_horizontal |= Control.SIZE_EXPAND
			fake_tile.size_flags_vertical |= Control.SIZE_EXPAND
			fake_tile.ignore_texture_size = true;
			fake_tile.stretch_mode = TextureButton.STRETCH_SCALE;
			fake_tile.pressed.connect(_swap_tile.bind(i));
			tile_grid.add_child(fake_tile);
		else:
			fake_tile = tile_grid.get_child(i);
		fake_tile.texture_normal = tile_texture(level.tiles[i]);
	var tile_size: float = Board.get_tile_size(playfield.size.x, level.size);
	var tile_scale: float = tile_size / Tile.BASE_SIZE;
	playfield.position.y = (tile_size * 1.5) if level.size > 3 else tile_size;
	
	enemy.scale = Vector2(tile_scale, tile_scale);
	enemy.position.x = SCREEN_WIDTH / 2;
	player.scale = Vector2(tile_scale, tile_scale);
	player.position.y = playfield.position.y + playfield.size.y;
	if level.size > 3: player.position.y += tile_size / 2;
	player.position.x = SCREEN_WIDTH / 2;
	if level.size % 2 == 0:
		enemy.position.x += tile_size / 2;
		player.position.x += tile_size / 2;
	
	bullet_button.position.y = player.position.y;
	bullet_button.size.y = tile_size;
	bullet_button.size.x = SCREEN_WIDTH;
	
	#if bullets.get_child_count() != level.bullets:
	for child in bullets.get_children():
		child.queue_free();
	for bullet_index in level.bullets:
		var bullet: Sprite2D = BULLET_INDICATOR_SCENE.instantiate();
		bullet.scale = player.scale;
		bullet.position.y = player.position.y;
		bullet.position.x = player.position.x + (tile_size / 2 + Board.PADDING) * (bullet_index + .5);
		bullets.add_child(bullet);
	
	
	menu_button.size = Vector2(tile_size, tile_size);
	save_button.size = Vector2(tile_size, tile_size);
	save_button.position.x = SCREEN_WIDTH - tile_size;
	
	var remaining_height = SCREEN_HEIGHT - player.position.y;
	var remaining_width = SCREEN_WIDTH - (SCREEN_WIDTH - player.position.x) - (512 * player.scale.x / 2);
	grid_size_container.position.y = player.position.y;
	grid_size_container.size = Vector2(remaining_width, remaining_height);

func tile_texture(id: int) -> Texture2D:
	match id:
		1: return BOX_TEXTURE;
		2: return WALL_TEXTURE;
		_: return null;

func save() -> void:
	var error := ResourceSaver.save(level, path);
	if error != Error.OK:
		error_label.visible = true;
		error_label.text = error_label.text % error;


func _swap_tile(index: int) -> void:
	level.tiles[index] = level.tiles[index] + 1 if level.tiles[index] < ShooterLevel.TILE_TYPES else 0;
	var child := tile_grid.get_children()[index];
	if child is TextureButton:
		(child as TextureButton).texture_normal = tile_texture(level.tiles[index]);
	else:
		layout();

func _add_bullet() -> void:
	level.bullets += 1;
	if level.bullets > ShooterLevel.MAX_BULLETS:
		level.bullets = 1;
	layout();


func _change_grid_size(add: int) -> void:
	level.size += add;
	if level.size < 3: level.size = 3;
	level.tiles.resize(level.size_squared());
	layout();
