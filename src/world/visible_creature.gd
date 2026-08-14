class_name VisibleCreature
extends Area2D

signal approached(creature_name: String, behavior: String)

@export var creature_name := "Mossling"
@export_enum("curious", "wary", "aggressive") var behavior := "curious"
@export var affinity_color := Color("#71a45b")
@export var creature_texture: Texture2D
var _player_nearby := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func interact() -> bool:
	if not _player_nearby:
		return false
	approached.emit(creature_name, behavior)
	return true


func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		_player_nearby = true


func _on_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		_player_nearby = false


func _draw() -> void:
	_draw_ellipse(Vector2(0, 21), Vector2(24, 9), Color(0.02, 0.05, 0.04, 0.48))
	if creature_texture != null:
		var display_height := 75.0
		var display_width := display_height * creature_texture.get_width() / creature_texture.get_height()
		draw_texture_rect(creature_texture, Rect2(-display_width * 0.5, -54, display_width, display_height), false)
		return
	draw_circle(Vector2.ZERO, 22.0, Color("#172422"))
	draw_circle(Vector2(0, 2), 18.0, affinity_color)
	draw_circle(Vector2(-14, -12), 9.0, affinity_color.lightened(0.12))
	draw_circle(Vector2(14, -12), 9.0, affinity_color.lightened(0.12))
	draw_circle(Vector2(-6, -1), 3.0, Color("#f3e6bd"))
	draw_circle(Vector2(6, -1), 3.0, Color("#f3e6bd"))
	draw_circle(Vector2(-6, -1), 1.5, Color("#172422"))
	draw_circle(Vector2(6, -1), 1.5, Color("#172422"))


func _draw_ellipse(center: Vector2, radii: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for index in 20:
		var angle := TAU * float(index) / 20.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, color)
