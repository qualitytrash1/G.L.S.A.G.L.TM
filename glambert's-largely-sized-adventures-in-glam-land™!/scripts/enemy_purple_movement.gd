class_name BasicEnemy

extends CharacterBody2D

@onready var hole_detector: RayCast2D = $HoleDetector
@onready var attack: AudioStreamPlayer = $Attack
@onready var hit_box_collision: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var smooth_animations: AnimationPlayer = $SmoothAnimations
@onready var body: CollisionShape2D = $Body
@onready var sparks: GPUParticles2D = $Sparks
@onready var always_emitting_sparks: Node2D = $PassiveSparks

@onready var sprite_parent: Node2D = $Sprite_Parent
@onready var sprite: Node2D = $Sprite

const SPEED: float = 800.0
const JUMP_VELOCITY: float = -400.0

var direction: int
var friction: float = 0.8
var old_pos_x: float
var flipped: bool = false

func _ready() -> void:
	
	#HAS FLIPPED TEXTURE
	if sprite_parent:
		flipped = false
		sprite_parent.get_child(flipped).show()
		sprite_parent.get_child(not flipped).hide()
	
	direction = -1
	sparks.emitting = false

func _physics_process(delta: float) -> void:
	
	
	if (not hole_detector.is_colliding()) or old_pos_x == position.x:
		#HAS FLIPPED TEXTURE (PLUG WALKS NEED A FLIPPED TEXTURE FOR SHADING TO BE CORRECT:
		#	MORE INFO: https://tenor.com/view/thumbs-up-two-thumbs-up-gif-6424432783867064329
		if sprite_parent:
			flipped = not flipped
			sprite_parent.get_child(flipped).show()
			sprite_parent.get_child(not flipped).hide()
		#FLIPS WITH CODE (CORD SNAKES DONT NEED A FLIPPED TEXTURE CUZ THEY'RE SHADED TOP DOWN
		elif sprite:
			sprite.flip_h = not sprite.flip_h
		
		hole_detector.position.x = -hole_detector.position.x
		direction = -direction
		velocity.x = 0
		always_emitting_sparks.position.x = -always_emitting_sparks.position.x
	
	old_pos_x = position.x
	velocity.x += (direction * SPEED) * delta
	velocity.x *= friction
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
