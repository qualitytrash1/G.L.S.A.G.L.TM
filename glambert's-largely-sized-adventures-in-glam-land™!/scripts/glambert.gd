extends CharacterBody2D

class_name Glambert

#MAX AND CONSTANTS
const GROUND_FRICTION: float = 0.9
const AIR_FRICTION: float = 0.98
const WALL_FRICTION: float = 0.9
const MAX_COYOTE_TIME: float = 0.08
const MAX_WALL_COYOTE_TIME: float = 0.175
const MAX_BUFFER_JUMP: float = 0.1
const MAX_JUMPS: int = 1
const BASE_SPEED: int = 1200
const BASE_WEIGHT: float = 1

#MOVEMENT
var coyote_time: float = MAX_COYOTE_TIME
var buffer_jump: float = MAX_BUFFER_JUMP
var speed: float = BASE_SPEED
var jump_velocity: float = -300.0
var friction: float = 0.9
var jumps: int = MAX_JUMPS
var wall_jumps: int = 0
var fall_time : float = 0
var wall_time : float = 0
var in_air: bool = false
var on_wall: bool = false
var weight: float = BASE_WEIGHT
var ground_pounding: bool = false
var ground_pound_time: float = 0
var direction : float = 0
var last_wall_normal : Vector2
var last_wall_jump_normal : Vector2
var last_vel : Vector2

#ANIMATION
var flipped: bool = false
var current_animation: String
var slipping: bool = false

#SPRITES
@onready var sprite_facing_left: AnimatedSprite2D = $Model/Sprites/SpriteFacingLeft
@onready var sprite_facing_right: AnimatedSprite2D = $Model/Sprites/SpriteFacingRight
@onready var sprites: Node2D = $Model/Sprites
@onready var glambert_sunglasses: Sprite2D = $Model/Sprites/GlambertSunglasses
@onready var smooth_animations: AnimationPlayer = $SmoothAnimations
@onready var statue_outline: Control = $UI/Control/Statues/StatueOutline
#SOUNDS
@onready var boing: AudioStreamPlayer = $Boing
@onready var soda_can_open: AudioStreamPlayer = $SodaCanOpen
@onready var stone_sliding: AudioStreamPlayer = $StoneSliding
@onready var finish_level: AudioStreamPlayer = $FinishLevel
@onready var punch: AudioStreamPlayer = $Punch
@onready var swishlast: AudioStreamPlayer = $Swishlast
@onready var slip: AudioStreamPlayer = $Slip
#MISC
@onready var camera: Camera2D = $"../../Camera"
@onready var iced_tea_texts: RichTextLabel = $UI/Control/IcedTeaTexts
@onready var statues: HBoxContainer = $UI/Control/Statues
@onready var level_text: RichTextLabel = $UI/Control/LevelText


func _ready() -> void:
	
	#SETS MOVEMENT VARIABLES
	ground_pound_time = 0
	weight = BASE_WEIGHT
	ground_pounding = false
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
		
		var clone_statue_button = statue_outline.duplicate()
		
		statues.add_child(clone_statue_button)
		clone_statue_button.get_child(0).play("outline")
		
	#REMOVES OG OUTLINE
	statue_outline.queue_free()
	
	#SPAWN AND CAMERA STUFFS (STUF OREOS? 677!!!) AHAHAHAHHHAH GET IT GET IT AHAHAHAHA
	position = Globals.spawn_location
	camera.position.x = position.x
	camera.position.y = position.y - Globals.zoom_factor
	
	#GUI
	iced_tea_texts.text = "Iced-Teas: " + str(Globals.iced_teas)

func _physics_process(delta: float) -> void:
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("left", "right")
	
	#MAKES GROUNDPOUNDING GOOD
	if ground_pound_time > 0.08:
		if weight < 0:
			weight = BASE_WEIGHT * 8
	elif ground_pounding:
		weight = -0.2
	
	#NOT IN AIR
	if is_on_floor():
		in_air = false
		wall_jumps = 0
		fall_time = 0
		#RESETS WEIGHT
		if ground_pounding:
			weight = BASE_WEIGHT
			ground_pounding = false
			punch.play()
	#IN AIR
	else:
		#MAKES IT GO FASTER AS IT GOES DOWN
		if ground_pounding:
			
			ground_pound_time += delta
			weight += 0.08
		
		in_air = true
		fall_time += delta
		
	if is_on_wall_only() and (abs(last_vel.x) > 50 or on_wall) and not ground_pounding:
		print(fall_time)
		on_wall = true
		last_wall_normal = get_wall_normal()
		wall_time += delta
		sprites.rotation = lerp(sprites.rotation, deg_to_rad(get_wall_normal().x * 90), delta * 24)
		ground_pounding = false
		ground_pound_time = 0
		#HOW LONG YOU CAN STAY ON WALL
		if wall_time < 0.75:
			slipping = false
			jumps = MAX_JUMPS
			coyote_time = MAX_WALL_COYOTE_TIME
			weight = 0.2
		else:
			if not slipping:
				slip.play()
			weight = 0.6
			slipping = true
	else:
		on_wall = false
		wall_time = 0
		sprites.rotation = lerp(sprites.rotation, deg_to_rad(get_floor_normal().x * 67.5), delta * 24)
		if not ground_pounding:
			weight = BASE_WEIGHT
			
	if in_air:
		#CHECKS IF PRESSING DOWN
		if Input.is_action_just_pressed("pound") and not ground_pounding and not on_wall:
			velocity.x = clamp(velocity.x, -80, 80)
			direction = 0
			velocity.y = -120
			ground_pound_time = 0
			swishlast.play()
			
			ground_pounding = true
			
		velocity += ((get_gravity() * weight) * delta)
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
		
	if jumps > 0 and buffer_jump > 0 and (not on_wall or (on_wall and wall_time > 0.12)) and (coyote_time > 0 or (fall_time > 0.1)):
		var same_wall_jump : bool = wall_jumps > 1 and round(last_wall_jump_normal.x) == round(last_wall_normal.x)
		if coyote_time <= 0 or (not same_wall_jump or (same_wall_jump and jumps == MAX_JUMPS)):
			if on_wall:
				velocity.x = last_wall_normal.x * 200
				wall_jumps += 1
			else:
				if jumps == MAX_JUMPS:
					fall_time = 0
			position.x += last_wall_normal.x * 2
			boing.play()
			if coyote_time <= 0:
				jumps -= 1
			coyote_time = 0
			buffer_jump = 0
			velocity.y = jump_velocity
			if same_wall_jump:
				jumps -= 1
				velocity.y += ((wall_jumps - 1) * 50)
				velocity.y = clamp(velocity.y, -10000, -140)
			weight = BASE_WEIGHT
			ground_pounding = false
			ground_pound_time = 0
			if on_wall:
				last_wall_jump_normal = last_wall_normal

	

	
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
	if on_wall and weight <= 0.5:
		velocity.y *= WALL_FRICTION
		
	velocity.y = clamp(velocity.y, jump_velocity * 5, -jump_velocity * 5)
	velocity.x = clamp(velocity.x, -BASE_SPEED, BASE_SPEED)
	
	camera.global_position = lerp(camera.global_position, global_position, 0.08)
	
	set_animation(current_animation)
	falling_animation(delta)
	last_vel = velocity
	move_and_slide()
	

func flip():
	var flip_dir : bool = false #false = left, true = right
	if on_wall:
		flip_dir = last_wall_normal.x > 0
	else:
		flip_dir = velocity.x < 0
	if flip_dir:
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
		sprites.scale = lerp(Vector2(1.0,1.0), Vector2(0.7 / (1 + (weight * 0.1)), 1.3 * (1 + (weight * 0.1))), fall_time)
		if on_wall:
			var old_scale : Vector2 = sprites.scale
			sprites.scale = Vector2(old_scale.y, old_scale.x)
		sprites.scale.x = clamp(sprites.scale.x, 0.75, 1.25)
		sprites.scale.y = clamp(sprites.scale.y, 0.75, 1.25)
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
			
			statues.get_child(Globals.statues).get_child(0).play("full")
			
			area.get_child(1).queue_free()
			
			stone_sliding.play()
			Globals.statues += 1
			
			area.get_child(2).play("dissapear")
			
			await area.get_child(2).animation_finished
		#COMPUTER
		if area.is_in_group("computer"):
			end_level(area, 0.4, true)


func end_level(node: Node, time: float, level_complete: bool):
		#GOES TO NEXT LEVEL
		
		if level_complete:
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

#SPIKE COLLISION
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("insta-death"):
		end_level(self, 0, false)
