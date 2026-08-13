class_name PlayerController
extends CharacterBody2D

@export var movement_speed := 220.0
var input_enabled := true


func _physics_process(_delta: float) -> void:
	if not input_enabled:
		velocity = Vector2.ZERO
		return
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * movement_speed
	move_and_slide()
	global_position.x = clampf(global_position.x, 28.0, 1892.0)
	global_position.y = clampf(global_position.y, 28.0, 1052.0)


func _draw() -> void:
	draw_circle(Vector2.ZERO, 18.0, Color("#173f39"))
	draw_circle(Vector2(0, -4), 13.0, Color("#d7aa62"))
	draw_rect(Rect2(-12, -23, 24, 8), Color("#4a2c23"))
	draw_rect(Rect2(-8, -30, 16, 10), Color("#7f4b2d"))
	draw_circle(Vector2(-5, -5), 2.0, Color("#241b18"))
	draw_circle(Vector2(5, -5), 2.0, Color("#241b18"))
