extends CharacterBody2D

class_name Glambert

const GROUND_FRICTION: float = 0.9
const AIR_FRICTION: float = 0.98
const MAX_COYOTE_TIME: float = 0.08
const MAX_BUFFER_JUMP: float = 0.08
const MAX_JUMPS: int = 1

var coyote_time: float = MAX_COYOTE_TIME
var buffer_jump: float = MAX_BUFFER_JUMP
var speed: float = 1200.0
var jump_velocity: float = -300.0
var friction: float = 0.9
var jumps: int = MAX_JUMPS
var fall_time : float = 0

var flipped: bool = false
var current_animation: String
var in_air: bool = false


#SPRITES
@onready var sprite_facing_left: AnimatedSprite2D = $Model/Sprites/SpriteFacingLeft
@onready var sprite_facing_right: AnimatedSprite2D = $Model/Sprites/SpriteFacingRight
@onready var sprites: Node2D = $Model/Sprites
@onready var glambert_sunglasses: Sprite2D = $Model/Sprites/GlambertSunglasses
@onready var smooth_animations: AnimationPlayer = $SmoothAnimations
#SOUNDS
@onready var boing: AudioStreamPlayer = $Boing

@onready var camera: Camera2D = $"../Camera"

func _ready() -> void:
	buffer_jump = 0
	jumps = MAX_JUMPS
	coyote_time = MAX_COYOTE_TIME
	friction = GROUND_FRICTION
	current_animation = "idle"
	flip()

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
