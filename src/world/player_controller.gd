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
	global_position.x = clampf(global_position.x, 12.0, 1908.0)
	global_position.y = clampf(global_position.y, 12.0, 1076.0)


func _draw() -> void:
	# The complete player silhouette fits a single 24 x 24 pixel box.
	draw_ellipse(Vector2(0, 9), 10.0, 3.0, Color(0.02, 0.05, 0.04, 0.5))
	draw_rect(Rect2(-9, 1, 18, 10), Color("#285f52"))
	draw_rect(Rect2(-8, -7, 16, 10), Color("#d7aa62"))
	draw_rect(Rect2(-10, -9, 20, 4), Color("#4a2c23"))
	draw_rect(Rect2(-6, -12, 12, 4), Color("#7f4b2d"))
	draw_rect(Rect2(-5, -3, 2, 2), Color("#241b18"))
	draw_rect(Rect2(3, -3, 2, 2), Color("#241b18"))
	draw_rect(Rect2(-6, 8, 4, 4), Color("#173f39"))
	draw_rect(Rect2(2, 8, 4, 4), Color("#173f39"))
