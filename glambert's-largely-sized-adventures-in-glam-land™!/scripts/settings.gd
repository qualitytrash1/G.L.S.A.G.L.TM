extends CanvasLayer

@onready var volume_icon: AnimatedSprite2D = $Settings/TabContainer/Audio/VolumeToggle/VolumeIcon
@onready var volume: Control = $Settings/TabContainer/Audio/Volume
@onready var pop_sound: AudioStreamPlayer = $Settings/PopSound
@onready var menu: Control = $Menu
@onready var settings: Control = $Settings
#SLIDERS
@onready var master_volume: HSlider = $Settings/TabContainer/Audio/Volume/MasterVolume
@onready var sound_volume: HSlider = $Settings/TabContainer/Audio/Volume/SoundVolume
@onready var music_volume: HSlider = $Settings/TabContainer/Audio/Volume/MusicVolume
@onready var particle_multiplier: HSlider = $Settings/TabContainer/Video/ParticleMultiplier
#CHECKBOXES
@onready var enable_filter: CheckBox = $Settings/TabContainer/Video/EnableFilter
@onready var vsync: CheckBox = $Settings/TabContainer/Video/Vsync
@onready var show_fps: CheckBox = $Settings/TabContainer/Video/ShowFPS
#OTHER
@onready var anim: AnimationPlayer = $Anim
@onready var max_fps: SpinBox = $Settings/TabContainer/Video/MaxFPS

var in_settings: bool = false

func _ready() -> void:
	get_tree().paused = false
	
	in_settings = false
	#SET SETTINGS FROM GLOBAL VARS
	#SLIDERS
	master_volume.value = Globals.master_vol
	sound_volume.value = Globals.sound_vol
	music_volume.value = Globals.music_vol
	#CHECKBOXES
	enable_filter.button_pressed = Globals.enable_filter
	vsync.button_pressed = Globals.vsync_enabled
	show_fps.button_pressed = Globals.show_fps
	#APPLY SETTINGS
	_on_master_volume_value_changed(Globals.master_vol)
	_on_sound_volume_value_changed(Globals.sound_vol)
	_on_music_volume_value_changed(Globals.music_vol)
	_on_enable_filter_toggled(Globals.enable_filter)
	#OTHER
	max_fps.value = Globals.max_fps
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("escape"):
		#OPENS SETTINHGS
		if not Globals.in_menu:
			open_menu()
		#CLOSES SETTINGS
		else:
			if not in_settings:
				close_menu()
			else:
				#CLOSE SETTINGS
				in_settings = false
				settings.hide()
				open_menu()

func open_menu():
	menu.show()
	anim.play("open")
	get_tree().paused = true
	Globals.in_menu = true
	var tween : Tween = create_tween()
	tween.tween_property(AudioServer.get_bus_effect(1,0), "cutoff_hz", 600, 0.1)
	
func close_menu():
	menu.hide()
	anim.play("close")
	get_tree().paused = false
	Globals.in_menu = false
	var tween : Tween = create_tween()
	tween.tween_property(AudioServer.get_bus_effect(1,0), "cutoff_hz", 20500, 0.1)
	await tween.finished

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
		Globals.master_vol = 2
		Globals.sound_vol = 2
		Globals.music_vol = 2
		master_volume.value = Globals.master_vol
		sound_volume.value = Globals.sound_vol
		music_volume.value = Globals.music_vol
		_on_master_volume_value_changed(Globals.master_vol)
		_on_sound_volume_value_changed(Globals.sound_vol)
		_on_music_volume_value_changed(Globals.music_vol)
		
		AudioServer.set_bus_mute(0, false)
		for i: HSlider in volume.get_children():
			i.editable = true
		


func _on_master_volume_value_changed(value: float) -> void:
	Globals.master_vol = value
	AudioServer.set_bus_volume_linear(0, value / 2)
	pop_sound.bus = &"Master"
	pop_sound.play()

func _on_sound_volume_value_changed(value: float) -> void:
	Globals.sound_vol = value
	AudioServer.set_bus_volume_linear(2, value / 2)
	pop_sound.bus = &"Sounds"
	pop_sound.play()
	

func _on_music_volume_value_changed(value: float) -> void:
	Globals.music_vol = value
	AudioServer.set_bus_volume_linear(1, value / 2)
	pop_sound.bus = &"Music"
	pop_sound.play()
	


func _on_enable_filter_toggled(toggled_on: bool) -> void:
	Globals.enable_filter = toggled_on
	if Globals.filter_node:
		Globals.filter_node.visible = Globals.enable_filter


func _on_resume_pressed() -> void:
	close_menu()


func _on_settings_pressed() -> void:
	in_settings = true
	settings.show()
	menu.hide()


func _on_exit_pressed() -> void:
	in_settings = false
	settings.hide()
	open_menu()


func _on_vsync_toggled(toggled_on: bool) -> void:
	Globals.vsync_enabled = toggled_on
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_show_fps_toggled(toggled_on: bool) -> void:
	Globals.show_fps = toggled_on


func _on_spin_box_value_changed(value: float) -> void:
	Globals.max_fps = value
	if value > 0:
		Engine.max_fps = value
	else:
		Engine.max_fps = 99999
