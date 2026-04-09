extends CharacterBody3D
class_name Glambert3D

const SPEED : float = 2.0

var input_dir : Vector2
var direction : Vector3
var vel : Vector2

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		vel = lerp(vel, Vector2(direction.x,direction.z) * SPEED, delta * 20)
	else:
		vel = lerp(vel, Vector2(0,0), delta * 30)
	velocity.x = vel.x
	velocity.z = vel.y
	move_and_slide()
