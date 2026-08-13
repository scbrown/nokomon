class_name Main
extends Control


func _ready() -> void:
	if not OS.has_feature("web"):
		get_viewport().get_window().min_size = Vector2i(640, 360)
