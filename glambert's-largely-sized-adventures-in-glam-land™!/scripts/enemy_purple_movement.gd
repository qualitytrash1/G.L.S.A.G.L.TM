extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var hole_detector: RayCast2D = $HoleDetector
@onready var attack: AudioStreamPlayer = $Attack
@onready var hit_box_collision: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var smooth_animations: AnimationPlayer = $SmoothAnimations
@onready var body: CollisionShape2D = $Body

const SPEED = 800.0
const JUMP_VELOCITY = -400.0

var direction: int
var friction: float = 0.8
var old_pos_x: float

func _ready() -> void:
	direction = -1

func _physics_process(delta: float) -> void:
	
	
	if (not hole_detector.is_colliding()) or old_pos_x == position.x:
		
		sprite.flip_h = (not sprite.flip_h)
		hole_detector.position.x = -hole_detector.position.x
		direction = -direction
		velocity.x = 0
	
	old_pos_x = position.x
	velocity.x += (direction * SPEED) * delta
	velocity.x *= friction
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()


func _on_hitbox_area_entered(area: Area2D) -> void:
	
	if area.get_parent() is Glambert:
		
		if area.get_parent().ground_pounding:
			
			body.queue_free()
			hit_box_collision.queue_free()
			
			smooth_animations.play("death")
			await smooth_animations.animation_finished
			queue_free()
		
		else:
			area.get_parent().end_level(self, 0, false)
