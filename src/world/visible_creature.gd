class_name VisibleCreature
extends Area2D

signal approached(creature_name: String, behavior: String)

@export var creature_name := "Mossling"
@export_enum("curious", "wary", "aggressive") var behavior := "curious"
@export var affinity_color := Color("#71a45b")
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
	draw_circle(Vector2.ZERO, 22.0, Color("#172422"))
	draw_circle(Vector2(0, 2), 18.0, affinity_color)
	draw_circle(Vector2(-14, -12), 9.0, affinity_color.lightened(0.12))
	draw_circle(Vector2(14, -12), 9.0, affinity_color.lightened(0.12))
	draw_circle(Vector2(-6, -1), 3.0, Color("#f3e6bd"))
	draw_circle(Vector2(6, -1), 3.0, Color("#f3e6bd"))
