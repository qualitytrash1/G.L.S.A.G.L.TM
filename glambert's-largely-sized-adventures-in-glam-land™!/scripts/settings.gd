extends CanvasLayer

@onready var volume_icon: AnimatedSprite2D = $Control/TabContainer/Audio/VolumeToggle/VolumeIcon
@onready var volume: Control = $Control/TabContainer/Audio/Volume
@onready var master_volume: HSlider = $Control/TabContainer/Audio/Volume/MasterVolume
@onready var sound_volume: HSlider = $Control/TabContainer/Audio/Volume/SoundVolume
@onready var music_volume: HSlider = $Control/TabContainer/Audio/Volume/MusicVolume
@onready var enable_filter: CheckBox = $"Control/TabContainer/Video/Enable Filter"
@onready var pop_sound: AudioStreamPlayer = $Control/PopSound



func _ready() -> void:
	get_tree().paused = false
	hide()
	
	#SET SETTINGS FROM GLOBAL VARS
	master_volume.value = Globals.master_vol
	sound_volume.value = Globals.sound_vol
	music_volume.value = Globals.music_vol
	enable_filter.button_pressed = Globals.enable_filter
	#APPLY SETTINGS
	AudioServer.set_bus_volume_linear(0, Globals.master_vol)
	AudioServer.set_bus_volume_linear(2, Globals.sound_vol)
	AudioServer.set_bus_volume_linear(1, Globals.music_vol)
	if Globals.filter_node:
		Globals.filter_node.visible = Globals.enable_filter
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape"):
		#OPENS SETTINHGS
		if not Globals.in_settings:
			show()
			get_tree().paused = true
			Globals.in_settings = true
		#CLOSES SETTINGS
		else:
			hide()
			get_tree().paused = false
			Globals.in_settings = false

func _on_volume_toggle_pressed() -> void:
	
	Globals.volume_on = not Globals.volume_on
	volume_icon.play(str(Globals.volume_on))
	
	if not Globals.volume_on:
		pop_sound.bus = &"Master"
		pop_sound.play()
		AudioServer.set_bus_mute(0, true)
		for i: HSlider in volume.get_children():
			i.editable = false
			i.value = 0
	else:
		Globals.master_vol = 1
		Globals.sound_vol = 1
		Globals.music_vol = 1
		master_volume.value = Globals.master_vol
		sound_volume.value = Globals.sound_vol
		music_volume.value = Globals.music_vol
		AudioServer.set_bus_volume_linear(0, Globals.master_vol)
		AudioServer.set_bus_volume_linear(2, Globals.sound_vol)
		AudioServer.set_bus_volume_linear(1, Globals.music_vol)
		
		AudioServer.set_bus_mute(0, false)
		for i: HSlider in volume.get_children():
			i.editable = true
		


func _on_master_volume_value_changed(value: float) -> void:
	Globals.master_vol = value
	AudioServer.set_bus_volume_linear(0, value)
	pop_sound.bus = &"Master"
	pop_sound.play()

func _on_sound_volume_value_changed(value: float) -> void:
	Globals.sound_vol = value
	AudioServer.set_bus_volume_linear(2, value)
	pop_sound.bus = &"Sounds"
	pop_sound.play()
	

func _on_music_volume_value_changed(value: float) -> void:
	Globals.music_vol = value
	AudioServer.set_bus_volume_linear(1, value)
	pop_sound.bus = &"Music"
	pop_sound.play()
	


func _on_enable_filter_toggled(toggled_on: bool) -> void:
	Globals.enable_filter = toggled_on
	if Globals.filter_node:
		Globals.filter_node.visible = Globals.enable_filter
