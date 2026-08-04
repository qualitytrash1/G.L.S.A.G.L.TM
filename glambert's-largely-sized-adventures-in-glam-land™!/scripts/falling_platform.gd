extends Node2D

@export var speed : float = 1

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var sound: AudioStreamPlayer2D = $Sound
@onready var anim: AnimationPlayer = $Anim
@onready var chunks: Node2D = $Chunks
@onready var collision: CollisionPolygon2D = $CharacterBody2D/CollisionPolygon2D

var y_vel : float = 0
var cracked : bool = false
var timer : SceneTreeTimer
var falling : bool = false
var original_pos : Vector2
var ground_pounding : bool = false
var glambert_near : bool = false
var glambert : Glambert

var chunk_y_vels : Dictionary[Node, float] = {}

func _ready() -> void:
	original_pos = position

func _on_detect_glambert_body_entered(body: Node2D) -> void:
	if body is Glambert:
		var already_ground_pounding : bool = ground_pounding and (cracked or falling)
		if already_ground_pounding:
			return
		if not ground_pounding:
			ground_pounding = body.time_since_ground_pound < 0.1
		if (not cracked) or (cracked and ground_pounding):
			falling = false
			cracked = false
			glambert = body
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
		if not ground_pounding:
			sprite.speed_scale = speed
			cracked = true
			crack()
			sprite.play("cracked")
			sound.play()
			await get_tree().create_timer(2.0 / speed).timeout
		else:
			y_vel = 100
			sprite.speed_scale = 9999
			sprite.play("cracked")
			sound.play()
		timer = get_tree().create_timer(3) #HOW LONG IT FALLS FOR
		falling = true
		
func _physics_process(delta: float) -> void:
	if cracked:
		chunk_fall(delta)
	if falling:
		y_vel += 8
		position.y += y_vel * delta
		if timer.time_left <= 0:
			collision.disabled = true
			sprite.play("default")
			anim.play("appear")
			position.y = original_pos.y
			for i : Node in chunk_y_vels:
				i.hide()
				i.position.y = 0
				chunk_y_vels.erase(i)
			falling = false
			cracked = false
			y_vel = 0
			await get_tree().create_timer(0).timeout
			collision.disabled = false
			


func _on_detect_ground_pound_body_entered(body: Node2D) -> void:
	if body is Glambert:
		glambert_near = true
		while glambert_near:
			if body.ground_pounding:
				ground_pounding = true
			else:
				if not falling:
					ground_pounding = false
			await get_tree().create_timer(0).timeout


func _on_detect_ground_pound_body_exited(body: Node2D) -> void:
	if body is Glambert:
		glambert_near = false
