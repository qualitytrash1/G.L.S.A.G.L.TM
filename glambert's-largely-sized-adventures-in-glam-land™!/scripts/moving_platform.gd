extends Node2D



@export var points: Array[Vector2]
@export var speed_multiplier: float

@onready var moving_platform: AnimatableBody2D = $AnimatedBody

var index: int = 0
var on_screen: bool = false

signal is_on_screen

func _ready() -> void:
	index = 0
	on_screen = false
	
	
	await is_on_screen
	#CHECKS IF POINTS HAS DATA
	if not points.is_empty():
		#SETS POSITION TO FIRST POSITION ON POINTS
		moving_platform.position = points[index]
		#FOREVER
		while true:
			await get_tree().create_timer(0).timeout
			if on_screen:
				if index < len(points) - 1:
					index += 1
				else:
					index = 0
				#SMOOTHLY ANIMATES
				var tween: Tween = create_tween()
				tween.tween_property(moving_platform, "position", points[index], abs((points[index].x + points[index].y) / 20) * speed_multiplier)
				
				await tween.finished
			
			


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	on_screen = true
	is_on_screen.emit()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	on_screen = false
