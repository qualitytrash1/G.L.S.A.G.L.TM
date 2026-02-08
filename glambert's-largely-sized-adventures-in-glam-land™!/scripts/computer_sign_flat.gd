@tool

extends Node2D

@onready var text: RichTextLabel = $Sprite/Screen/Text
@onready var collision_shape_2d: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var sign_hover: AnimationPlayer = $SignHover

@export var sign_text: String
@export var offset: int
@export var has_collision: bool
@export var floating_platform: bool
@export var speed : float

var on_screen_status: bool = false

signal on_screen

func _ready() -> void:
	
	if floating_platform:
		sign_hover.play("hover")

	#SETS VARS
	text.text = ""
	text.size.x = 1
	text.text = sign_text + "   "
	text.position = Vector2(29, -5)
	var text_size : float = text.size.x
	text.text += sign_text + "   " + sign_text + "   " #double text
	
	if not has_collision:
		collision_shape_2d.disabled = true
	else:
		collision_shape_2d.disabled = false
		
	while true:
		if not on_screen_status and not Engine.is_editor_hint():
			#RESET AND WAIT FOR ON SCREEN
			text.position = Vector2(29, -5)
			await on_screen
	
		while true:
			await get_tree().create_timer(0.1).timeout
			text.position.x -= speed
			if text.position.x < (-text_size * 2) * text.scale.x:
				text.position.x += (text_size * 1) * text.scale.x
				break


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	emit_signal("on_screen")
	on_screen_status = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	on_screen_status = false
