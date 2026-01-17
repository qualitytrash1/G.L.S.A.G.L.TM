extends Node


@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer



func _ready() -> void:
	
	audio_stream_player.stream = load(Globals.level_data[Globals.current_level]["song"])
	audio_stream_player.play()
