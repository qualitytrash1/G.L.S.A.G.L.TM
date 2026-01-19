extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	if Globals.check_points.has(position.x):
		queue_free()
