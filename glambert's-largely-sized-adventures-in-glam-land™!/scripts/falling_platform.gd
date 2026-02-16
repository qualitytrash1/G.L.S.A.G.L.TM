extends Node2D

@export var speed : float = 1

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var sound: AudioStreamPlayer2D = $Sound
@onready var anim: AnimationPlayer = $Anim
@onready var chunks: Node2D = $Chunks

var y_vel : float = 0
var cracked : bool = false
var timer : SceneTreeTimer
var falling : bool = false
var original_pos : Vector2

var chunk_y_vels : Dictionary[Node, float] = {}

func _ready() -> void:
	original_pos = position

func _on_detect_glambert_body_entered(body: Node2D) -> void:
	if not cracked:
		if body is Glambert:
			fall()
		
func crack() -> void:
	await get_tree().create_timer(1.0 / speed).timeout
	chunk_y_vels[chunks.get_child(0)] = 0
	await get_tree().create_timer((1.0 / speed) - randf_range(0.03,0.06)).timeout
	chunk_y_vels[chunks.get_child(1)] = 0
	await get_tree().create_timer(randf_range(0.01,0.03)).timeout
	chunk_y_vels[chunks.get_child(2)] = 0
	await get_tree().create_timer(0).timeout
	chunk_y_vels[chunks.get_child(3)] = 0
	
func chunk_fall(delta : float) -> void:
	for i : Node in chunk_y_vels:
		chunk_y_vels[i] += delta * 2
		i.position.y += chunk_y_vels[i]
		i.show()
		
func fall() -> void:
	if not cracked:
		sprite.speed_scale = speed
		y_vel = 0
		cracked = true
		crack()
		sprite.play("cracked")
		sound.play()
		await get_tree().create_timer(2.0 / speed).timeout
		timer = get_tree().create_timer(3) #HOW LONG IT FALLS FOR
		falling = true
		
func _process(delta: float) -> void:
	if cracked:
		chunk_fall(delta)
	if falling:
		y_vel += delta * 2
		position.y += y_vel
		if timer.time_left <= 0:
			sprite.play("default")
			anim.play("appear")
			position.y = original_pos.y
			for i : Node in chunk_y_vels:
				i.hide()
				i.position.y = 0
				chunk_y_vels.erase(i)
			falling = false
			cracked = false
			
