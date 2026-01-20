extends Node

#CHANGE ON FINAL EXPORT (disables debug features)
var final_export : bool = false

var iced_teas: int = 0
var statues: int = 0
var statue_amount: int
var spawn_location: Vector2 = Vector2(0, 0)
var zoom_factor: float = 1000
var current_level: int = 0
var camera_y_limit: float = 10000
var has_checkpoint: bool = false
var lives: int = 5

#SETTINGS
var in_settings: bool = false

#VOLUME
var volume_on: bool = true
var master_vol: float = 1
var sound_vol: float = 1
var music_vol: float = 1

#VIDEO
var enable_filter: bool = false
var filter_node: ColorRect


var level_data: Array[Dictionary] = [
	{"level": 1, "time": 400, "song": "uid://c1ckqndnn46hb"},
	{"level": 2, "time": 400, "song": "uid://bsn7u4s87ur8q"},
	{"level": 3, "time": 400, "song": "uid://c64v154ca7onu"}
]
var check_points: Array = []
