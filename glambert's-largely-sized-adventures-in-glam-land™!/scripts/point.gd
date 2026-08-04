extends Node2D

@onready var level : Node2D = $"../../"
@onready var button: Button = $Button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(level.point_pressed.bind(self))
