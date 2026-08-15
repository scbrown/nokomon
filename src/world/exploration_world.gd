class_name ExplorationWorld
extends Node2D

signal encounter_requested(creature_name: String, behavior: String)

const ATLAS: Texture2D = preload("res://assets/vendor/kenney_roguelike_rpg/atlas.png")
const FLOOR_TILE: Texture2D = preload("res://assets/world/floor.png")
const SRMIMILGHEL_TEXTURE: Texture2D = preload("res://assets/creatures/srmimilghel/battle.png")
const ATLAS_STEP := 17
const TILE_SIZE := 16
const GRID_SIZE := 32
const WORLD_SIZE := Vector2i(1920, 1088)
# The source image has a one-pixel border around its 32 px tile artwork.
const FLOOR_SOURCE_REGION := Rect2(1, 1, GRID_SIZE, GRID_SIZE)

var player: PlayerController
var _creatures: Array[VisibleCreature] = []


func _ready() -> void:
	_build_boundaries()
	_build_scenery()
	player = PlayerController.new()
	player.name = "Player"
	player.position = Vector2(430, 500)
	player.add_to_group("player")
	add_child(player)
	_add_player_collision()

	var camera := Camera2D.new()
	camera.position_smoothing_enabled = true
	camera.position_smoothing_speed = 7.0
	camera.limit_left = 0
	camera.limit_top = 0
	camera.limit_right = WORLD_SIZE.x
	camera.limit_bottom = WORLD_SIZE.y
	player.add_child(camera)

	_spawn_creature("Mossling", "curious", Vector2(1180, 430), Color("#6f9d55"))
	_spawn_creature("Cindervole", "wary", Vector2(1460, 720), Color("#b86537"))
	_spawn_creature("Gloamoth", "aggressive", Vector2(1670, 330), Color("#75638f"))
	_spawn_creature("Srmimilghel", "wary", Vector2(1056, 672), Color("#9a7448"), SRMIMILGHEL_TEXTURE)
	queue_redraw()


func try_interact() -> bool:
	for creature in _creatures:
		if creature.interact():
			return true
	return false


func set_player_input_enabled(enabled: bool) -> void:
	player.input_enabled = enabled


func _spawn_creature(
	name_value: String,
	behavior_value: String,
	spawn_position: Vector2,
	color: Color,
	texture: Texture2D = null
) -> void:
	var creature := VisibleCreature.new()
	creature.creature_name = name_value
	creature.behavior = behavior_value
	creature.affinity_color = color
	creature.creature_texture = texture
	creature.position = spawn_position
	creature.approached.connect(encounter_requested.emit)
	add_child(creature)

	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 62.0
	shape.shape = circle
	creature.add_child(shape)
	_creatures.append(creature)


func _add_player_collision() -> void:
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(20, 20)
	shape.shape = rectangle
	player.add_child(shape)


func _build_boundaries() -> void:
	for data: Array in [
		[Vector2(960, -16), Vector2(1920, 32)],
		[Vector2(960, 1104), Vector2(1920, 32)],
		[Vector2(-16, 544), Vector2(32, 1088)],
		[Vector2(1936, 544), Vector2(32, 1088)],
	]:
		var body := StaticBody2D.new()
		body.position = data[0]
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = data[1]
		shape.shape = rectangle
		body.add_child(shape)
		add_child(body)


func _build_scenery() -> void:
	# Vendor tiles are temporary scaffolding. Their placement establishes density,
	# layers, and scale while original Nokomon environment art is developed.
	for position_value: Vector2 in [
		Vector2(930, 210), Vector2(1080, 175), Vector2(1260, 190),
		Vector2(1450, 165), Vector2(1650, 205), Vector2(1840, 250),
		Vector2(1010, 870), Vector2(1210, 940), Vector2(1450, 915),
		Vector2(1690, 900), Vector2(1850, 790),
	]:
		_add_shadow(position_value + Vector2(0, 22), Vector2(48, 18))
		_add_atlas_tile(Vector2i(18, 10), position_value, 4.0, Color("#bdd28c"), 2)

	for position_value: Vector2 in [
		Vector2(970, 360), Vector2(1110, 310), Vector2(1320, 300),
		Vector2(1520, 290), Vector2(1740, 380), Vector2(1160, 810),
		Vector2(1390, 830), Vector2(1600, 790), Vector2(1800, 680),
	]:
		_add_atlas_tile(Vector2i(23, 10), position_value, 3.0, Color("#9dbc73"), 1)

	for position_value: Vector2 in [Vector2(885, 470), Vector2(935, 470), Vector2(985, 470), Vector2(1035, 470)]:
		_add_atlas_tile(Vector2i(43, 14), position_value, 3.0, Color("#d0a466"), 1)

	for position_value: Vector2 in [
		Vector2(125, 330), Vector2(360, 350), Vector2(705, 335),
		Vector2(115, 850), Vector2(455, 850), Vector2(740, 850),
	]:
		_add_atlas_tile(Vector2i(44, 22), position_value, 3.0, Color("#b77942"), 3)

	for position_value: Vector2 in [Vector2(465, 395), Vector2(700, 585), Vector2(790, 395)]:
		_add_atlas_tile(Vector2i(30, 8), position_value, 3.0, Color("#ffd16a"), 3)

	for position_value: Vector2 in [Vector2(540, 845), Vector2(600, 845), Vector2(660, 845)]:
		_add_atlas_tile(Vector2i(45, 13), position_value, 3.0, Color("#d8b27b"), 3)


func _add_atlas_tile(cell: Vector2i, position_value: Vector2, scale_value: float, tint: Color, z: int) -> void:
	var texture := AtlasTexture.new()
	texture.atlas = ATLAS
	texture.region = Rect2(cell.x * ATLAS_STEP, cell.y * ATLAS_STEP, TILE_SIZE, TILE_SIZE)
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = position_value
	sprite.scale = Vector2.ONE * scale_value
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.modulate = tint
	sprite.z_index = z
	add_child(sprite)


func _add_shadow(position_value: Vector2, size_value: Vector2) -> void:
	var shadow := Polygon2D.new()
	shadow.polygon = PackedVector2Array([
		Vector2(-size_value.x, 0), Vector2(-size_value.x * 0.6, -size_value.y),
		Vector2(size_value.x * 0.6, -size_value.y), Vector2(size_value.x, 0),
		Vector2(size_value.x * 0.6, size_value.y), Vector2(-size_value.x * 0.6, size_value.y),
	])
	shadow.position = position_value
	shadow.color = Color(0.03, 0.08, 0.05, 0.45)
	shadow.z_index = 0
	add_child(shadow)


func _draw() -> void:
	for y in range(0, WORLD_SIZE.y, GRID_SIZE):
		for x in range(0, WORLD_SIZE.x, GRID_SIZE):
			draw_texture_rect_region(
				FLOOR_TILE,
				Rect2(x, y, GRID_SIZE, GRID_SIZE),
				FLOOR_SOURCE_REGION
			)
	# Transparent regional tints preserve the floor texture while distinguishing
	# the settlement soil and deeper woodland.
	draw_rect(Rect2(40, 90, 820, 900), Color(0.35, 0.19, 0.12, 0.48))
	draw_rect(Rect2(860, 250, 1060, 610), Color(0.08, 0.18, 0.09, 0.34))
	draw_rect(Rect2(790, 430, 360, 140), Color("#926741"))
	# Small deterministic marks break up broad flat fields without visual noise.
	var random := RandomNumberGenerator.new()
	random.seed = 1900
	for index in 260:
		var point := Vector2(random.randi_range(65, 830), random.randi_range(110, 970))
		draw_rect(Rect2(point, Vector2(3, 3)), Color(0.24, 0.15, 0.11, 0.28))
	for index in 420:
		var point := Vector2(random.randi_range(875, 1900), random.randi_range(265, 845))
		draw_rect(Rect2(point, Vector2(3, 5)), Color(0.45, 0.62, 0.32, 0.24))
	# Paths layer lighter edges over darker soil to suggest wear and height.
	draw_rect(Rect2(780, 421, 380, 158), Color(0.12, 0.16, 0.11, 0.35))
	draw_rect(Rect2(790, 430, 360, 140), Color("#926741"))
	draw_line(Vector2(810, 447), Vector2(1130, 447), Color("#bd8b57"), 3)
	# Settlement buildings and clinic.
	for rect: Rect2 in [Rect2(110, 150, 230, 150), Rect2(410, 130, 260, 180), Rect2(170, 650, 270, 180)]:
		draw_rect(Rect2(rect.position + Vector2(12, 18), rect.size), Color(0.08, 0.06, 0.05, 0.52))
		draw_rect(rect, Color("#3d281f"))
		draw_colored_polygon(PackedVector2Array([rect.position + Vector2(-18, 18), rect.position + Vector2(rect.size.x * 0.5, -42), rect.position + Vector2(rect.size.x + 18, 18)]), Color("#8d4b31"))
		draw_rect(Rect2(rect.position + Vector2(12, 20), rect.size - Vector2(24, 32)), Color("#9b5a36"))
		draw_rect(Rect2(rect.position + Vector2(rect.size.x * 0.5 - 22, rect.size.y - 62), Vector2(44, 62)), Color("#38271f"))
		draw_rect(Rect2(rect.position + Vector2(28, 55), Vector2(42, 36)), Color("#edbd60"))
	draw_rect(Rect2(500, 620, 270, 190), Color("#e2d3ad"))
	draw_rect(Rect2(516, 636, 238, 158), Color("#cbbd98"), false, 5)
	draw_rect(Rect2(530, 650, 210, 130), Color("#396858"))
	draw_colored_polygon(PackedVector2Array([Vector2(485, 650), Vector2(635, 580), Vector2(785, 650)]), Color("#4d3025"))
	draw_circle(Vector2(635, 638), 26, Color("#e7d59e"))
	draw_rect(Rect2(628, 620, 14, 36), Color("#3b725f"))
	draw_rect(Rect2(617, 631, 36, 14), Color("#3b725f"))
	draw_string(ThemeDB.fallback_font, Vector2(557, 717), "CLINIC", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("#f1dfad"))
	# Railway and forest detail.
	draw_rect(Rect2(40, 465, 780, 104), Color("#302c27"))
	for x in range(50, 800, 48):
		draw_rect(Rect2(x, 470, 28, 90), Color("#5a4534"))
	draw_line(Vector2(40, 485), Vector2(820, 485), Color("#b88b4d"), 8)
	draw_line(Vector2(40, 545), Vector2(820, 545), Color("#b88b4d"), 8)
	draw_line(Vector2(40, 482), Vector2(820, 482), Color("#e0b96c"), 2)
	draw_line(Vector2(40, 542), Vector2(820, 542), Color("#e0b96c"), 2)
	draw_string(ThemeDB.fallback_font, Vector2(110, 75), "BRASSLEAF SETTLEMENT", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("#f0d390"))
	draw_string(ThemeDB.fallback_font, Vector2(1150, 210), "FERNWOOD MARGIN", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("#dce7bd"))
