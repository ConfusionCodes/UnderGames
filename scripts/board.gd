extends Node2D
class_name Board

const PADDING = 16.0;

static func get_tile_size(playfield_size: float, grid_size: int) -> float:
	return (playfield_size - PADDING * 2) / grid_size;

@onready var playfield: NinePatchRect = %Playfield
@onready var enemy: Enemy = %Enemy
@onready var player: Sprite2D = %Player
@onready var slide_sfx: AudioStreamPlayer = %SlideSfx
@onready var shoot_sfx: AudioStreamPlayer = %ShootSfx
@onready var menu_button: Button = %MenuButton
@onready var reset_button: Button = %ResetButton
@onready var menu: BoardUi = %Menu
@onready var notification_panel: Panel = %NotificationPanel
@onready var notification_label: Label = %NotificationLabel

@export_group("Scenes")
@export var LEVEL_SELECT_SCENE: PackedScene;
@export var BOX_SCENE: PackedScene;
@export var WALL_SCENE: PackedScene;
@export var BULLET_INDICATOR_SCENE: PackedScene;
@export var BULLET_SCENE: PackedScene;
@export_group("Settings")
@export var level: ShooterLevel = preload("res://levels/debug.tres");
@export var bullets: int = 2;

var tile_size: float = 0.0 :
	set(value):
		tile_size = value;
		tile_scale = tile_size / Tile.BASE_SIZE;
var tile_scale: float = 1.0;
var contents: Array[Tile] = [];
var tween: Tween = null;
var extra_frame: bool = false;

func _ready() -> void:
	if OS.has_feature("android"):
		var darkened: StyleBoxFlat = StyleBoxFlat.new();
		darkened.bg_color = Color.from_rgba8(0, 0, 0, 192);
		notification_panel.material = PlaceholderMaterial.new();
		notification_panel.add_theme_stylebox_override("panel", darkened);
		menu.material = PlaceholderMaterial.new();
		menu.add_theme_stylebox_override("panel", darkened);
	if not BOX_SCENE or not WALL_SCENE:
		printerr("Failed to initialize tile scenes; Aborting...");
		return;
	if SceneManager.current_level:
		load_level(SceneManager.current_level);
	else:
		load_level(level);

func load_level(new_level: ShooterLevel) -> void:
	player.position = Vector2.ZERO;
	player.scale = Vector2.ONE;
	for child in player.get_children():
		if child is Sprite2D:
			player.remove_child(child);
	enemy.position = Vector2.ZERO;
	enemy.scale = Vector2.ONE;
	for tile in contents:
		if tile and is_instance_valid(tile) and !tile.is_queued_for_deletion():
			tile.queue_free();
	contents.clear();
	
	level = new_level;
	bullets = level.bullets;
	tile_size = get_tile_size(playfield.size.x, level.size);
	var error := contents.resize(level.size_squared());\
	if error != Error.OK:
		printerr("Failed to resize contents array: %d" % error);
	for i in range(level.tiles.size()):
		match level.tiles[i]:
			0: contents[i] = null;
			1: contents[i] = BOX_SCENE.instantiate();
			2: contents[i] = WALL_SCENE.instantiate(); 
	place_decorations();
	place_contents();
	if level.notification != "":
		var split := level.notification.split("\n|\n");
		if split.size() > 1 && OS.has_feature("android"):
			notification_label.text = split[1];
		else:
			notification_label.text = split[0];
	else:
		notification_panel.visible = false;
		menu.is_open = false;
	


func place_decorations() -> void:
	enemy.scale = Vector2(tile_scale, tile_scale);
	enemy.reset();
	if level.size % 2 == 0:
		enemy.position.x = 360 + tile_size / 2;
		player.position.x = 360 + tile_size / 2;
	else:
		enemy.position.x = 360;
		player.position.x = 360;
	playfield.position.y = tile_size * 1.25;
	player.scale = Vector2(tile_scale, tile_scale);
	player.position.y = (playfield.position.y + playfield.size.y + tile_size * 0.25);
	player.position.y = min(
		player.position.y, 
		get_viewport_rect().size.y - (Tile.BASE_SIZE * player.scale.y)
	);
	
	for i in range(bullets):
		var indicator: Sprite2D = BULLET_INDICATOR_SCENE.instantiate();
		player.add_child(indicator);
		indicator.position = Vector2((Tile.BASE_SIZE * 0.25) + (Tile.BASE_SIZE / 2 + PADDING) * i, 0);
	
	menu_button.size = Vector2(tile_size, tile_size);
	reset_button.size = Vector2(tile_size, tile_size);
	reset_button.position.x = get_viewport_rect().size.x - tile_size;

func place_contents() -> void:
	var target_scale := tile_size / Tile.BASE_SIZE;
	for index in range(level.size_squared()):
		var tile: Tile = contents[index];
		if tile == null:
			continue;
		playfield.add_child(tile);
		
		tile.scale = Vector2(target_scale, target_scale);
		var y := index / level.size;
		var x := index % level.size;
		tile.position.x = (tile_size * x) + PADDING + tile_size / 2;
		tile.position.y = (tile_size * y) + PADDING + tile_size / 2;


func _process(_delta: float) -> void:
	if !(menu.is_open):
		process_input();

func process_input() -> void:
	if tween and tween.is_running(): 
		extra_frame = true;
		return;
	if extra_frame:
		extra_frame = false;
		return;
	if Input.is_action_just_pressed("left"):
		move_tiles(func(i: int) -> int: return i % level.size == 0, -1, Vector2.LEFT);
	elif Input.is_action_just_pressed("right"):
		move_tiles(func(i: int) -> int: return i % level.size == level.size - 1, 1, Vector2.RIGHT);
	elif Input.is_action_just_pressed("up"):
		move_tiles(func(i: int) -> int: return i / level.size == 0, -level.size, Vector2.UP);
	elif Input.is_action_just_pressed("down"):
		move_tiles(func(i: int) -> int: return i / level.size == level.size - 1, level.size, Vector2.DOWN);
	elif Input.is_action_just_pressed("shoot"):
		shoot();
	elif Input.is_action_just_pressed("restart"):
		load_level(level);
		
	elif Input.is_action_just_pressed("debug_refresh"):
		place_contents();

func move_tiles(edge_condition: Callable, neghbor: int, direction: Vector2) -> void:
	var play_sfx: bool = false;
	var index_range := range(level.size_squared());
	if direction.x > 0 or direction.y > 0: index_range.reverse();
	for index: int in index_range:
		var tile: Tile = contents[index];
		if !is_instance_valid(tile) or tile.is_queued_for_deletion():
			contents[index] = null;
		if !tile or tile is not Box:
			continue;
		if edge_condition.call(index): continue;
		if contents[index + neghbor] == null:
			play_sfx = true;
			if !tween or !tween.is_valid(): tween = get_tree().create_tween().set_parallel(true);
			var tween_result := tween.tween_property(tile, "position", direction * tile_size, 0.25)
			if !tween_result: tile.position += direction * tile_size;
			else: 
				tween_result.as_relative();
			contents[index] = null;
			contents[index + neghbor] = tile;
	if play_sfx: slide_sfx.play();

func shoot() -> void:
	var indicator: Node = player.get_children().pop_back();
	if indicator is Sprite2D:
		player.remove_child(indicator);
	else:
		return
	var bullet: Bullet = BULLET_SCENE.instantiate();
	bullet.position = player.position;
	bullet.scale = player.scale;
	self.add_child(bullet);
	shoot_sfx.play();


func _on_notification_dismissed() -> void:
	notification_panel.visible = false;
	menu.is_open = false;
