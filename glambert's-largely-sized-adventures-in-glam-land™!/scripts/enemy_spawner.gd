extends Node2D

class_name EnemySpawner

enum Enemies {
	SHORT_CORD_SNAKE,
	LONG_CORD_SNAKE,
	PURPLE_PLUG_WALK
}

@export var enemy_to_spawn: Enemies

var enemies: Array[Dictionary] = [
	{"name": "Short Cord Snake", "address": "uid://bxh6mbpbm8fhm"},
	{"name": "Long Cord Snake", "address": "uid://kqdgnurmgg2c"},
	{"name": "Purple Plug Walk", "address": "uid://8ml8rkvcnoyg"},
]

var on_screen: bool
var enemy: PackedScene

#ON SCREEN
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	#SPAWNS ENEMY
	enemy = load(enemies[enemy_to_spawn]["address"])
	var clone_enemy: CharacterBody2D = enemy.instantiate()
	add_child(clone_enemy)
#OFF SCREEN
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#DESPAWNS ENEMY
	for i: Node2D in get_children():
		
		if i.is_in_group("enemy-spawner"):
			continue
			
		i.queue_free()
