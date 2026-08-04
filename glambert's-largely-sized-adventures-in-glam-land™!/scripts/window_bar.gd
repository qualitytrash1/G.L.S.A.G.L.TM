##A custom task-bar node that looks cool and retro.

extends CanvasLayer

class_name WindowBar

@onready var bar: Control = $Bar

var evil_mouse_hovering : bool = false
var mouse_hovering : bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	check_visibility()


func _on_close_button_pressed() -> void:
	get_tree().quit()

func _on_max_button_pressed() -> void:
	#FULLSCREEN
	if get_window().mode == Window.MODE_MAXIMIZED:
		get_window().mode = Window.MODE_WINDOWED
		
	#WINDOWED
	elif get_window().mode == Window.MODE_WINDOWED:
		get_window().mode = Window.MODE_MAXIMIZED
	
	check_visibility()

func _on_minus_button_pressed() -> void:
	get_window().mode = Window.MODE_MINIMIZED

func check_visibility() -> void:
	if Globals.full_screen:
		hide()
		Globals.window_bar_visible = false
	else:
		show()
		Globals.window_bar_visible = true


func _on_window_bar_mouse_entered() -> void:
	evil_mouse_hovering = true
	while evil_mouse_hovering: #WHILE MOUSE OVER:
		#NO START HOVER IF HOLDING MOUSE
		while Input.is_action_just_pressed("click"):
			await get_tree().create_timer(0).timeout
		mouse_hovering = true
		#WAIT UNTIL CLICK
		while not Input.is_action_just_pressed("click"):
			await get_tree().create_timer(0).timeout
		#DRAG WINDOW
		if mouse_hovering:
			var start_offset : Vector2 = Vector2i(DisplayServer.mouse_get_position()) - DisplayServer.window_get_position()
			if get_window().mode == Window.MODE_MAXIMIZED:
				get_window().mode = Window.MODE_WINDOWED
			await get_tree().create_timer(0).timeout
			var start_pos : Vector2 = DisplayServer.mouse_get_position()
			var last_mouse_pos : Vector2 = start_pos
			while Input.is_action_pressed("click"):
				var mouse_pos : Vector2 = DisplayServer.mouse_get_position()
				var distance : Vector2 = mouse_pos - last_mouse_pos
				var current_offset : Vector2i = DisplayServer.mouse_get_position() - DisplayServer.window_get_position()
				if (distance.y > 0 and current_offset.y < start_offset.y) \
				or (distance.y < 0 and not current_offset.y < start_offset.y):
					distance.y = 0
				if (distance.x > 0 and current_offset.x < start_offset.x) \
				or (distance.x < 0 and not current_offset.x < start_offset.x):
					distance.x = 0
				var final_pos : Vector2 = DisplayServer.window_get_position() + Vector2i(distance)
				var screen_size : Vector2i = DisplayServer.screen_get_size(DisplayServer.window_get_current_screen())
				DisplayServer.window_set_position(Vector2i(clamp(final_pos.x, 0, screen_size.x - DisplayServer.window_get_size().x), clamp(final_pos.y, 0, screen_size.y - DisplayServer.window_get_size().y)))
				last_mouse_pos = mouse_pos
				await get_tree().create_timer(0).timeout
				
			mouse_hovering = false


func _on_control_mouse_exited() -> void:
	evil_mouse_hovering = false
	while Input.is_action_pressed("click"):
		await get_tree().create_timer(0).timeout
	mouse_hovering = false
