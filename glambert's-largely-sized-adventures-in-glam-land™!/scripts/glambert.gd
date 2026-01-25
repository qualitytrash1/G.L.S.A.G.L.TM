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
const MAX_JUMP_HEIGHT: float = -312
const GROUND_PARTICLE_COUNT: int = 10
const MIN_TIME_SINCE_GROUND_POUND : float = 0.05

#MOVEMENT
var speed: float = BASE_SPEED
var jump_velocity: float
var friction: float = 0.9
var jumps: int = MAX_JUMPS
var wall_jumps: int = 0
var in_air: bool = false
var on_wall: bool = false
var weight: float = BASE_WEIGHT
var ground_pounding: bool = false
var direction : float = 0
var last_wall_normal : Vector2
var last_wall_jump_normal : Vector2
var last_vel : Vector2
var high_jump: bool = false
var jump_height: float = MAX_JUMP_HEIGHT
var crouching: bool = false
var jumping: bool = false
var cut_jump: bool = false

#TIMERS
var fall_time : float = 0
var wall_time : float = 0
var coyote_time: float = MAX_COYOTE_TIME
var buffer_jump: float = MAX_BUFFER_JUMP
var ground_pound_time: float = 0
var time_since_ground_pound : float = 0

#ANIMATION
var flipped: bool = false
var current_animation: String
var slipping: bool = false
var visual_crouching: bool

#OTHER
var dying: bool = false
var bodies_in_crouch: int = 0
var bodies_in_uncrouch: int = 0

#SPRITES
@onready var sprite_facing_left: AnimatedSprite2D = $Model/Sprites/SpriteFacingLeft
@onready var sprite_facing_right: AnimatedSprite2D = $Model/Sprites/SpriteFacingRight
@onready var crouch_facing_left: AnimatedSprite2D = $Model/Sprites/CrouchFacingLeft
@onready var crouch_facing_right: AnimatedSprite2D = $Model/Sprites/CrouchFacingRight
@onready var sprites: Node2D = $Model/Sprites
@onready var glambert_sunglasses: Sprite2D = $Model/Sprites/GlambertSunglasses
@onready var smooth_animations: AnimationPlayer = $SmoothAnimations
@onready var statue_outline: Control = $UI/Control/Statues/StatueOutline
@onready var sunglasses_no_shading: Sprite2D = $UI/Control/SunglassesNoShading
#SOUNDS
@onready var ding: AudioStreamPlayer = $Ding
@onready var boing: AudioStreamPlayer = $Boing
@onready var soda_can_open: AudioStreamPlayer = $SodaCanOpen
@onready var stone_sliding: AudioStreamPlayer = $StoneSliding
@onready var finish_level: AudioStreamPlayer = $FinishLevel
@onready var punch: AudioStreamPlayer = $Punch
@onready var swishlast: AudioStreamPlayer = $Swishlast
@onready var slip: AudioStreamPlayer = $Slip
@onready var attack: AudioStreamPlayer = $Attack
@onready var squish: AudioStreamPlayer = $Squish
@onready var pop: AudioStreamPlayer = $Pop
@onready var power_up: AudioStreamPlayer = $PowerUp
#MISC
@onready var fps: RichTextLabel = $UI/FPS
@onready var camera: Camera2D = $"../../Camera"
@onready var iced_tea_texts: RichTextLabel = $UI/Control/IcedTeaTexts
@onready var statues: HBoxContainer = $UI/Control/Statues
@onready var level_text: RichTextLabel = $UI/Control/LevelText
@onready var circle_collision: CollisionShape2D = $CircleCollision
@onready var chromatic_abberation: ColorRect = $UI/Control/ChromaticAbberation
@onready var ground_particles: GPUParticles2D = $Ground
@onready var ground_pound_particles: GPUParticles2D = $GroundPound
@onready var normal_collision: CollisionShape2D = $NormalCollision
@onready var normal_collision_2: CollisionShape2D = $NormalCollision2
@onready var crouch_collision: CollisionShape2D = $CrouchCollision
@onready var normal_hitbox: CollisionShape2D = $Hitbox/NormalHitbox
@onready var normal_hitbox_2: CollisionShape2D = $Hitbox/NormalHitbox2
@onready var crouch_hitbox: CollisionShape2D = $Hitbox/CrouchHitbox
@onready var bottom_gradient: TextureRect = $"../BottomGradient"
@onready var lives: RichTextLabel = $UI/Control/Lives


func _ready() -> void:

	get_tree().paused = false
	
	if Globals.show_fps:
		fps.show()
	else:
		fps.hide()
	
	#SETS MOVEMENT VARIABLES
	crouching = false
	ground_pound_time = 0
	weight = BASE_WEIGHT
	ground_pounding = false
	speed = BASE_SPEED
	buffer_jump = 0
	jumps = MAX_JUMPS
	coyote_time = MAX_COYOTE_TIME
	friction = GROUND_FRICTION
	jump_velocity = MAX_JUMP_HEIGHT
	#OTHER VARS
	dying = false
	Globals.filter_node = chromatic_abberation
	#VISUAL THINGS
	ground_particles.emitting = false
	current_animation = "idle"
	
	
	
	flip()
	
	await get_tree().create_timer(0).timeout
	
	#CREATES THE RIGHT AMOUNT OF OUTLINES FOR STATUES IN LEVEL
	for i: int in range(Globals.statue_amount):
		
		var clone_statue_button: Control = statue_outline.duplicate()
		
		statues.add_child(clone_statue_button)
		clone_statue_button.get_child(0).play("outline")
		
	#REMOVES OG OUTLINE
	statue_outline.queue_free()
	
	#SPAWN AND CAMERA STUFFS (STUF OREOS? 677!!!) AHAHAHAHHHAH GET IT GET IT AHAHAHAHA
	position = Globals.spawn_location
	#CAMERA
	camera.position.x = position.x
	camera.position.y = position.y - Globals.zoom_factor
	#SETS CAMERA LIMITS
	camera.limit_bottom = Globals.camera_y_limit
	camera.limit_left = Globals.camera_left_limit
	camera.limit_right = Globals.camera_right_limit
	
	bottom_gradient.position.y = Globals.camera_y_limit - bottom_gradient.size.y
	
	#GUI
	iced_tea_texts.text = "Iced-Teas: " + str(Globals.iced_teas)
	level_text.text = "Level: #" + str(Globals.current_level + 1)
	set_lives()

func _physics_process(delta: float) -> void:
	
	if Globals.show_fps:
		fps.show()
	else:
		fps.hide()
	
	fps.text = "FPS: " + str(Engine.get_frames_per_second())
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_axis("left", "right")
	if abs(direction) < 0.4:
		direction = 0
	
	#MAKES GROUNDPOUNDING GOOD
	if ground_pound_time > 0.08:
		if weight < 0:
			weight = BASE_WEIGHT * 8
	elif ground_pounding:
		weight = -0.2
	
	#NOT IN AIR
	if is_on_floor():
		in_air = false
		jumping = false
		wall_jumps = 0
		fall_time = 0
		#RESETS WEIGHT
		if ground_pounding:
			weight = BASE_WEIGHT
			time_since_ground_pound = 0
			ground_pounding = false
			punch.play()
			stone_sliding.play()
			ground_pound_particles.restart()
			if abs(get_floor_normal().x) > 0:
				velocity.x = get_floor_normal().x * 1000
				rotation = lerp(rotation, get_floor_angle() * (get_floor_normal().x / abs(get_floor_normal().x)), delta * 24)
			#PLAY ANIMATION
			uncrouch(true)
	#IN AIR
	else:
		#MAKES IT GO FASTER AS IT GOES DOWN
		if ground_pounding:
			
			ground_pound_time += delta
			weight += 0.08
		
		
			
		in_air = true
		fall_time += delta
		
	if (is_on_wall_only() and (abs(last_vel.x) > 50 or on_wall) and not ground_pounding):
		rotation = 0
		on_wall = true
		jumping = false
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
		sprites.rotation = lerp(sprites.rotation, 0.0, delta * 24)
		if not in_air:
			if get_floor_angle():
				rotation = lerp(rotation, get_floor_angle() * (get_floor_normal().x / abs(get_floor_normal().x)), delta * 24)
			else:
				rotation = 0
		if not ground_pounding:
			weight = BASE_WEIGHT
			
	if in_air:
		rotation = 0
		ground_particles.emitting = false
		#CHECKS IF PRESSING DOWN
		if Input.is_action_just_pressed("pound") and not ground_pounding and not on_wall:
			
			velocity.x = clamp(velocity.x, -80, 80)
			direction = 0
			velocity.y = jump_velocity / 1.25
			ground_pound_time = 0
			swishlast.play()
			ground_pounding = true
			
		velocity += ((get_gravity() * weight) * delta)
		
		#CUT JUMP
		if Input.is_action_just_released("jump") and jumping:
			cut_jump = true
	else:
		if Input.is_action_pressed("crouch") and not ground_pounding and not on_wall and not crouching and bodies_in_crouch < 1:
			crouch()
			
		jumps = MAX_JUMPS
		coyote_time = MAX_COYOTE_TIME
		in_air = false
		
	if not Input.is_action_pressed("crouch") and crouching and bodies_in_uncrouch < 1: #uncrouch
		uncrouch()
		
	if coyote_time <= 0:
		if bodies_in_uncrouch < 1:
			uncrouch()
		
	#TIMER VARIABLES
	coyote_time -= delta
	buffer_jump -= delta
	time_since_ground_pound += delta

	#JUMPING
	
	#enable hold jump but only if on ground
	if (Input.is_action_pressed("jump") and coyote_time > 0 and not on_wall) or (Input.is_action_just_pressed("jump")):
		buffer_jump = MAX_BUFFER_JUMP
		
	if buffer_jump > 0 and time_since_ground_pound <= MIN_TIME_SINCE_GROUND_POUND:
		buffer_jump = MAX_BUFFER_JUMP
		
	if not jumping:
		cut_jump = false
		
	if cut_jump and velocity.y < -35 and not ground_pounding and wall_jumps == 0:
		velocity.y = lerp(velocity.y, -35.0, delta * (weight * 4))
		
		
	if jumps > 0 and buffer_jump > 0 and (not on_wall or (on_wall and wall_time > 0.12)) and (coyote_time > 0 or (fall_time > 0.1)) and time_since_ground_pound > MIN_TIME_SINCE_GROUND_POUND and bodies_in_uncrouch < 1:
		var same_wall_jump : bool = wall_jumps > 1 and round(last_wall_jump_normal.x) == round(last_wall_normal.x)
		if coyote_time <= 0 or (not same_wall_jump or (same_wall_jump and jumps == MAX_JUMPS)):
			jumping = true
			cut_jump = false
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
				velocity.y = clamp(velocity.y, -10000, -120)
			if time_since_ground_pound < MIN_TIME_SINCE_GROUND_POUND * 3:
				velocity.y += (jump_velocity / 4)
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
			if not crouching:
				speed = BASE_SPEED
			smooth_animations.speed_scale = 1
		if not in_air:
			ground_particles.emitting = true
		friction = GROUND_FRICTION
		glambert_sunglasses.position.x = direction * 5
		flip()
		current_animation = "walk"
	#COMMENT
	elif in_air:
		ground_particles.emitting = false
		friction = AIR_FRICTION
	
	if !direction and !in_air:
		ground_particles.emitting = false
		current_animation = "idle"
		friction = GROUND_FRICTION
	
	velocity.x *= friction
	if on_wall and weight <= 0.5:
		velocity.y *= WALL_FRICTION
		
	velocity.y = clamp(velocity.y, jump_velocity * 5, -jump_velocity * 5)
	velocity.x = clamp(velocity.x, -BASE_SPEED, BASE_SPEED)
	
	camera.global_position = lerp(camera.global_position, global_position, 0.08)
	camera.global_position = round(camera.global_position * 4) / 4
	bottom_gradient.position.x = camera.position.x - get_viewport_rect().size.x/2
	bottom_gradient.size.x = get_viewport_rect().size.x + 64
	
	if not crouching and not crouch_facing_left.is_playing():
		set_animation(current_animation)
	code_animation(delta)
	if crouching:
		#crouch hitboxes
		crouch_collision.disabled = false
		crouch_hitbox.disabled = false
		normal_collision.disabled = true
		normal_collision_2.disabled = true
		normal_hitbox.disabled = true
		normal_hitbox_2.disabled = true
	else:
		#normal hitboxes
		crouch_collision.disabled = true
		crouch_hitbox.disabled = true
		normal_collision.disabled = false
		normal_collision_2.disabled = false
		normal_hitbox.disabled = false
		normal_hitbox_2.disabled = false
	last_vel = velocity
	move_and_slide()
	set_collision_mask_value(4, (velocity.y >= 0 and not on_wall) or velocity.y >= 30) #disable platform collision if moving up


func flip():
	var flip_dir : bool = false #false = left, true = right
	if on_wall:
		flip_dir = last_wall_normal.x > 0
	else:
		flip_dir = velocity.x < 0
	#HIDE ALL
	for i: Node2D in sprites.get_children():
		if i == glambert_sunglasses:
			break
		i.hide() 
	if flip_dir:
		if visual_crouching:
			crouch_facing_right.show()
		else:
			sprite_facing_right.show()
		glambert_sunglasses.flip_h = true
	else:
		if visual_crouching:
			crouch_facing_left.show()
		else:
			sprite_facing_left.show()
		glambert_sunglasses.flip_h = false

func set_animation(animation: String):
	
	visual_crouching = crouching
	
	if animation == "crouch" or animation == "uncrouch":
		visual_crouching = true
	
	
	if visual_crouching:
		crouch_facing_left.play(animation)
		crouch_facing_right.play(animation)
	else:
		sprite_facing_left.play(animation)
		sprite_facing_right.play(animation)
		
	smooth_animations.play(animation)
	flip()
	if visual_crouching:
		await crouch_facing_left.animation_finished
		visual_crouching = crouching
		
		
func crouch(override : bool = false) -> void:
	if not crouching or override:
		crouching = false
		speed = BASE_SPEED / 2
		set_animation("crouch")
		squish.play()
	crouching = true
	
func uncrouch(override : bool = false) -> void:
	if crouching or override:
		crouching = true
		set_animation("uncrouch")
		speed = BASE_SPEED
		pop.play()
	crouching = false
	
func code_animation(delta : float) -> void:
	ground_particles.amount = GROUND_PARTICLE_COUNT * (1 + (((speed * abs(direction)) - BASE_SPEED) / BASE_SPEED))
	if in_air:
		sprites.scale = lerp(Vector2(1.0,1.0), Vector2(0.7 / (1 + (weight * 0.1)), 1.3 * (1 + (weight * 0.1))), fall_time)
		if on_wall:
			var old_scale : Vector2 = sprites.scale
			sprites.scale = Vector2(old_scale.y, old_scale.x)
		sprites.scale.x = clamp(sprites.scale.x, 0.75, 1.25)
		sprites.scale.y = clamp(sprites.scale.y, 0.75, 1.25)
	else:
		if crouching:
			glambert_sunglasses.position.y = lerp(glambert_sunglasses.position.y, 16.0, delta * 12)
		sprites.scale = lerp(sprites.scale, Vector2(1,1), delta * 30) #RESET
		glambert_sunglasses.position.y = lerp(glambert_sunglasses.position.y, 0.0, delta * 30) #RESET



func _on_hitbox_area_entered(area: Area2D) -> void:
	
	#IS A COLLECTABLE
	if area.is_in_group("insta-death"):
		end_level(self, 0, false)
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
		#CHECKPOINT
		if area.is_in_group("check-point"):
			ding.play()
			Globals.has_checkpoint = true
			Globals.spawn_location = area.position
			Globals.check_points.append(area.position.x)
			#ANIMATIONS
			var tween: Tween = create_tween()
			tween.set_parallel(true)
			tween.tween_property(area, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.25)
			tween.tween_property(area, "position", Vector2(area.position.x, area.position.y - 50), 0.3)
			await tween.finished
			
			area.queue_free()
		#LIFE
		if area.is_in_group("life"):
			
			area.get_child(1).queue_free()
			
			power_up.play()
			area.get_child(0).play("collect")
			
			Globals.lives += 1
			set_lives()
	
	#ENEMY
	if area.get_parent() is BasicEnemy:
		
		var enemy : BasicEnemy = area.get_parent()
		
		if ground_pounding or time_since_ground_pound <= 0.05:
			#jump
			coyote_time = MAX_COYOTE_TIME
			buffer_jump = MAX_BUFFER_JUMP
			time_since_ground_pound = 0
			ground_pounding = false
			
			
			attack.play()
			punch.play()
			
			#MAKES IT SO PARTICLES DONT CUT OFF
			var particles = enemy.sparks.duplicate()
			add_child(particles)
			particles.emitting = true
			
			enemy.body.queue_free()
			enemy.hit_box_collision.queue_free()
			
			enemy.smooth_animations.play("death")
			await enemy.smooth_animations.animation_finished
			enemy.queue_free()
			await particles.finished
			particles.queue_free()


		
		else:
			end_level(enemy, 0, false)


func end_level(node: Node, time: float, level_complete: bool):
		
		#GOES TO NEXT LEVEL
		if level_complete:
			
			Globals.check_points = []
			Globals.has_checkpoint = false
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
		#DIES
		else:
			Globals.lives -= 1
			dying = true
		get_tree().reload_current_scene()


func set_lives():
	var offset: int = 50
	for i: int in range(Globals.lives):
		
		var clone_sunglasses = sunglasses_no_shading.duplicate()
		
		lives.add_child(clone_sunglasses)
		clone_sunglasses.show()
		clone_sunglasses.scale = Vector2(5, 5)
		clone_sunglasses.position = Vector2(50, offset)
		
		offset -= 50


#SPIKE COLLISION
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("insta-death"):
		end_level(self, 0, false)


func _on_safe_to_crouch_body_entered(body: Node2D) -> void:
	if not body is Glambert:
		bodies_in_crouch += 1


func _on_safe_to_crouch_body_exited(body: Node2D) -> void:
	if not body is Glambert:
		bodies_in_crouch -= 1


func _on_safe_to_uncrouch_body_entered(body: Node2D) -> void:
	if not body is Glambert:
		bodies_in_uncrouch += 1


func _on_safe_to_uncrouch_body_exited(body: Node2D) -> void:
	if not body is Glambert:
		bodies_in_uncrouch -= 1
