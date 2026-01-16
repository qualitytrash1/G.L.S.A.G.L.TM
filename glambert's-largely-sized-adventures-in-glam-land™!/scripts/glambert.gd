extends CharacterBody2D

class_name Glambert

#MAX AND CONSTANTS
const GROUND_FRICTION: float = 0.9
const AIR_FRICTION: float = 0.98
const MAX_COYOTE_TIME: float = 0.08
const MAX_BUFFER_JUMP: float = 0.08
const MAX_JUMPS: int = 1
const BASE_SPEED: int = 1200

#MOVEMENT
var coyote_time: float = MAX_COYOTE_TIME
var buffer_jump: float = MAX_BUFFER_JUMP
var speed: float = BASE_SPEED
var jump_velocity: float = -300.0
var friction: float = 0.9
var jumps: int = MAX_JUMPS
var fall_time : float = 0
var in_air: bool = false
#ANIMATION
var flipped: bool = false
var current_animation: String


#SPRITES
@onready var sprite_facing_left: AnimatedSprite2D = $Model/Sprites/SpriteFacingLeft
@onready var sprite_facing_right: AnimatedSprite2D = $Model/Sprites/SpriteFacingRight
@onready var sprites: Node2D = $Model/Sprites
@onready var glambert_sunglasses: Sprite2D = $Model/Sprites/GlambertSunglasses
@onready var smooth_animations: AnimationPlayer = $SmoothAnimations
@onready var statue_outline: AnimatedSprite2D = $UI/Statues/Sprite
#SOUNDS
@onready var boing: AudioStreamPlayer = $Boing
@onready var soda_can_open: AudioStreamPlayer = $SodaCanOpen
@onready var stone_sliding: AudioStreamPlayer = $StoneSliding
@onready var finish_level: AudioStreamPlayer = $FinishLevel
#MISC
@onready var camera: Camera2D = $"../../Camera"
@onready var iced_tea_texts: RichTextLabel = $UI/IcedTeaTexts
@onready var statues: Node2D = $UI/Statues
@onready var level_text: RichTextLabel = $UI/LevelText

func _ready() -> void:
	
	#SETS MOVEMENT VARIABLES
	speed = BASE_SPEED
	buffer_jump = 0
	jumps = MAX_JUMPS
	coyote_time = MAX_COYOTE_TIME
	friction = GROUND_FRICTION
	#VISUAL THINGS
	current_animation = "idle"
	iced_tea_texts.text = "Iced-Teas: " + str(Globals.iced_teas)
	level_text.text = "Level: #" + str(Globals.current_level)
	flip()
	
	await get_tree().create_timer(0).timeout
	
	#CREATES THE RIGHT AMOUNT OF OUTLINES FOR STATUES IN LEVEL
	for i in range(Globals.statue_amount):
		
		var offset: int = -128
		var clone_statue_button = statue_outline.duplicate()
		
		statues.add_child(clone_statue_button)
		clone_statue_button.play("outline")
		
		clone_statue_button.position.x = statue_outline.position.x + (offset * i)
	#REMOVES OG OUTLINE
	statue_outline.queue_free()
	#SPAWN AND CAMERA STUFFS (STUF OREOS? 677!!!) AHAHAHAHHHAH GET IT GET IT AHAHAHAHA
	position = Globals.spawn_location
	camera.position.x = position.x
	camera.position.y = position.y - Globals.zoom_factor

func _physics_process(delta: float) -> void:
	# Add the gravity.
	
	
	
	if is_on_floor():
		in_air = false
		fall_time = 0
	else:
		in_air = true
		fall_time += delta
	
	if in_air:
		velocity += get_gravity() * delta
	else:
		jumps = MAX_JUMPS
		coyote_time = MAX_COYOTE_TIME
		in_air = false
		
	#SUBTRACT VARIABLES
	coyote_time -= delta
	buffer_jump -= delta
		

	# Handle jump.
	
	if Input.is_action_just_pressed("jump"):
		buffer_jump = MAX_BUFFER_JUMP
		
	if jumps > 0 and buffer_jump > 0:
		fall_time = 0
		boing.play()
		if coyote_time <= 0:
			jumps -= 1
		coyote_time = MAX_COYOTE_TIME
		buffer_jump = 0
		velocity.y = jump_velocity
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	
	glambert_sunglasses.position.x = lerp(glambert_sunglasses.position.x, direction * 4, 0.08)
	velocity.x += (direction * speed) * delta
	
	if direction:
		
		if Input.is_action_pressed("sprint"):
			speed = BASE_SPEED * 1.3
			smooth_animations.speed_scale = 2
		else:
			speed = BASE_SPEED
			smooth_animations.speed_scale = 1
		
		friction = GROUND_FRICTION
		glambert_sunglasses.position.x = direction * 5
		flip()
		current_animation = "walk"
	#COMMENT
	elif in_air:
		friction = AIR_FRICTION
	
	if !direction and !in_air:
		current_animation = "idle"
		friction = GROUND_FRICTION
	
	velocity.x *= friction
	
	camera.global_position = lerp(camera.global_position, global_position, 0.08)
	
	set_animation(current_animation)
	falling_animation(delta)
	move_and_slide()
	

func flip():
	if velocity.x < 0:
		sprite_facing_left.hide()
		sprite_facing_right.show()
		glambert_sunglasses.flip_h = true
	else:
		sprite_facing_left.show()
		sprite_facing_right.hide()
		glambert_sunglasses.flip_h = false

func set_animation(animation: String):
	
	sprite_facing_left.play(animation)
	sprite_facing_right.play(animation)
	smooth_animations.play(animation)
	
func falling_animation(delta : float) -> void:
	if in_air:
		fall_time = clamp(fall_time, 0, 1)
		sprites.scale = lerp(Vector2(1.0,1.0), Vector2(0.7,1.3), fall_time)
	else:
		sprites.scale = lerp(sprites.scale, Vector2(1,1), delta * 30)



func _on_hitbox_area_entered(area: Area2D) -> void:
	
	#IS A COLLECTABLE
	if area.is_in_group("collectable"):
		#ICE TEA
		if area.is_in_group("ice-tea"):
			
			area.get_child(1).queue_free()
			
			soda_can_open.play()
			area.get_child(0).play("collect")
			
			Globals.iced_teas += 1
			iced_tea_texts.text = "Iced-Teas: " + str(Globals.iced_teas)
			
			await area.get_child(0).animation_finished
			
			area.queue_free()
		#STATUE
		if area.is_in_group("statue"):
			
			statues.get_child(Globals.statues).play("full")
			
			area.get_child(1).queue_free()
			
			stone_sliding.play()
			Globals.statues += 1
			
			area.get_child(2).play("dissapear")
			
			await area.get_child(2).animation_finished
		#COMPUTER
		if area.is_in_group("computer"):
			end_level(area, 0.4)
			

func end_level(node: Node, time: float):
	#GOES TO NEXT LEVEL
		Globals.current_level += 1
		#ANIMATION
		var tween: Tween = create_tween()
		tween.set_parallel(true)
		#TWEENS
		tween.tween_property(self, "scale", Vector2(0, 0), time)
		tween.tween_property(self, "global_position", node.global_position, time)
		tween.tween_property(self, "modulate", Color(0.161, 0.294, 0.761, 1.0), time)
		tween.tween_property(camera, "zoom", (camera.zoom * 4), time)
		tween.tween_property(camera, "global_position", node.global_position, time)
		#NOISE
		finish_level.play()
		
		await tween.finished
		
		get_tree().reload_current_scene()
