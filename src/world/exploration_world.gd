class_name ExplorationWorld
extends Node2D

signal encounter_requested(creature_name: String, behavior: String)

var player: PlayerController
var _creatures: Array[VisibleCreature] = []


func _ready() -> void:
	_build_boundaries()
	_build_landmarks()
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
	camera.limit_right = 1920
	camera.limit_bottom = 1080
	player.add_child(camera)

	_spawn_creature("Mossling", "curious", Vector2(1180, 430), Color("#6f9d55"))
	_spawn_creature("Cindervole", "wary", Vector2(1460, 720), Color("#b86537"))
	_spawn_creature("Gloamoth", "aggressive", Vector2(1670, 330), Color("#75638f"))
	queue_redraw()


func try_interact() -> bool:
	for creature in _creatures:
		if creature.interact():
			return true
	return false


func set_player_input_enabled(enabled: bool) -> void:
	player.input_enabled = enabled


func _spawn_creature(name_value: String, behavior_value: String, spawn_position: Vector2, color: Color) -> void:
	var creature := VisibleCreature.new()
	creature.creature_name = name_value
	creature.behavior = behavior_value
	creature.affinity_color = color
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
	var circle := CircleShape2D.new()
	circle.radius = 16.0
	shape.shape = circle
	player.add_child(shape)


func _build_boundaries() -> void:
	for data: Array in [
		[Vector2(960, -16), Vector2(1920, 32)],
		[Vector2(960, 1096), Vector2(1920, 32)],
		[Vector2(-16, 540), Vector2(32, 1080)],
		[Vector2(1936, 540), Vector2(32, 1080)],
	]:
		var body := StaticBody2D.new()
		body.position = data[0]
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = data[1]
		shape.shape = rectangle
		body.add_child(shape)
		add_child(body)


func _build_landmarks() -> void:
	# Landmarks are deliberately simple prototype geometry, ready to be replaced by tiles.
	pass


func _draw() -> void:
	draw_rect(Rect2(0, 0, 1920, 1080), Color("#263f2c"))
	draw_rect(Rect2(40, 90, 820, 900), Color("#735138"))
	draw_rect(Rect2(860, 250, 1060, 610), Color("#304f31"))
	draw_rect(Rect2(790, 430, 360, 140), Color("#9b7146"))
	# Settlement buildings and clinic.
	for rect: Rect2 in [Rect2(110, 150, 230, 150), Rect2(410, 130, 260, 180), Rect2(170, 650, 270, 180)]:
		draw_rect(rect, Color("#4b3026"))
		draw_rect(Rect2(rect.position + Vector2(12, 12), rect.size - Vector2(24, 24)), Color("#a85e35"))
	draw_rect(Rect2(500, 620, 270, 190), Color("#e2d3ad"))
	draw_rect(Rect2(530, 650, 210, 130), Color("#396858"))
	draw_string(ThemeDB.fallback_font, Vector2(557, 717), "CLINIC", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("#f1dfad"))
	# Railway and forest detail.
	for x in range(50, 800, 48):
		draw_rect(Rect2(x, 470, 28, 90), Color("#3a3028"))
	draw_line(Vector2(40, 485), Vector2(820, 485), Color("#b88b4d"), 8)
	draw_line(Vector2(40, 545), Vector2(820, 545), Color("#b88b4d"), 8)
	for position_value: Vector2 in [Vector2(1030, 300), Vector2(1280, 250), Vector2(1540, 260), Vector2(1780, 500), Vector2(1050, 780), Vector2(1360, 880), Vector2(1700, 850)]:
		draw_circle(position_value, 58, Color("#173823"))
		draw_circle(position_value + Vector2(0, -12), 44, Color("#285c34"))
	draw_string(ThemeDB.fallback_font, Vector2(110, 75), "BRASSLEAF SETTLEMENT", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("#f0d390"))
	draw_string(ThemeDB.fallback_font, Vector2(1150, 210), "FERNWOOD MARGIN", HORIZONTAL_ALIGNMENT_LEFT, -1, 26, Color("#dce7bd"))
