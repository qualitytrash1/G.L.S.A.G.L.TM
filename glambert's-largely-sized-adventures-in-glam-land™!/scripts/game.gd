extends Node2D

@onready var statues: Node2D = $Statues

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.statue_amount = statues.get_child_count()
