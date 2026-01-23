extends Node2D

@onready var statues: Node2D = $Level/Interactable/Statues
@onready var glambert: Glambert = $Level/Glambert
@onready var computers: Node2D = $Level/Interactable/Computers
#BORDERS
@onready var death_barrier: Area2D = $Level/Borders/DeathBarrier
@onready var left_barrier: StaticBody2D = $Level/Borders/LeftBarrier
@onready var right_barrier: StaticBody2D = $Level/Borders/RightBarrier


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	set_start_and_end_computers()
	#SETS LIMITS
	Globals.camera_y_limit = death_barrier.position.y
	Globals.camera_left_limit = left_barrier.position.x
	Globals.camera_right_limit = right_barrier.position.x
	
	Globals.statue_amount = statues.get_child_count()
	Globals.iced_teas = 0
	Globals.statues = 0
	if Globals.lives < 1:
		Globals.lives = 5

func set_start_and_end_computers():
	
	# MODULAR CODE:
		# SETS THE FARTHEST LEFT COMPUTER TO START
		# AND FARTHEST RIGHT COMPUTER TO END
		# ALSO WILL BE GOOD FOR LEVEL EDITOR.
		# SCHUMNKY BUNGYTUNK
	
	var start_child: int
	var end_child: int
	
	end_child = int(computers.get_child(0).position.x < computers.get_child(1).position.x)
	start_child = int(computers.get_child(0).position.x > computers.get_child(1).position.x)
	
	#START COMPUTER
	computers.get_child(start_child).get_child(3).text = "Start"
	computers.get_child(start_child).set_meta("location", "end")
	computers.get_child(start_child).get_child(5).queue_free()
	#END COMPUTER
	computers.get_child(end_child).get_child(3).text = "End"
	computers.get_child(end_child).set_meta("location", "start")
	if (not Globals.has_checkpoint) or Globals.lives < 1:
		Globals.spawn_location = computers.get_child(start_child).position
