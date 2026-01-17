extends Node2D

@onready var statues: Node2D = $Level/Interactable/Statues
@onready var glambert: Glambert = $Level/Glambert
@onready var computers: Node2D = $Level/Interactable/Computers
@onready var death_barrier: Area2D = $Level/DeathBarrier


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	set_start_and_end_computers()
	Globals.camera_y_limit = death_barrier.position.y
	Globals.statue_amount = statues.get_child_count()
	Globals.iced_teas = 0
	Globals.statues = 0

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
	
	Globals.spawn_location = computers.get_child(start_child).position
