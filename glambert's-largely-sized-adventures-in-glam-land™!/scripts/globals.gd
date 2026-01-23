extends Node

#CHANGE ON FINAL EXPORT (disables debug features)
var final_export : bool = false

var iced_teas: int = 0
var statues: int = 0
var statue_amount: int
var spawn_location: Vector2 = Vector2(0, 0)
var zoom_factor: float = 250
var current_level: int = 0
#CAMERA LIMITS
var camera_y_limit: float = 10000
var camera_left_limit: float = 10000
var camera_right_limit: float = 10000

var has_checkpoint: bool = false
var lives: int = 5

#SETTINGS
var in_menu: bool = false

#VOLUME
var volume_on: bool = true
var master_vol: float = 2
var sound_vol: float = 2
var music_vol: float = 2

#VIDEO
var enable_filter: bool = true
var filter_node: ColorRect


var level_data: Array[Dictionary] = [
	{"level": 1, "time": 400, "song": "uid://c1ckqndnn46hb"},
	{"level": 2, "time": 400, "song": "uid://bsn7u4s87ur8q"},
	{"level": 3, "time": 400, "song": "uid://c64v154ca7onu"},
	{"level": 4, "time": 400, "song": "uid://bfj0n8ykh3tje"},
	{"level": 5, "time": 400, "song": "uid://b8b3pbis5sbb3"}


]
var check_points: Array = []
