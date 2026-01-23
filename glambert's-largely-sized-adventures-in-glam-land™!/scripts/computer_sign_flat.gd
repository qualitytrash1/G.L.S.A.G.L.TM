extends Node2D

@onready var text: RichTextLabel = $Sprite/Screen/Text
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var sign_hover: AnimationPlayer = $SignHover

@export var sign_text: String
@export var offset: int
@export var has_collision: bool
@export var floating_platform: bool

var index: int = 0


func _ready() -> void:
	
	if floating_platform:
		sign_hover.play("hover")

	#SETS VARS
	text.text = sign_text
	text.position = Vector2(-25, -5)
	
	index = len(text.text) + offset
	
	if not has_collision:
		collision_shape_2d.disabled = true
	else:
		collision_shape_2d.disabled = false
	
	while true:
		text.position = Vector2(29, -5)
		for i in range(index):
			await get_tree().create_timer(0.25).timeout
			text.position.x -= 4
