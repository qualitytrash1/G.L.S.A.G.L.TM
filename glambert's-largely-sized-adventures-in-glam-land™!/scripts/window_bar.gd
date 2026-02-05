##A custom task-bar node that looks cool and retro.

extends CanvasLayer

class_name WindowBar

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
	while Input.is_action_pressed("click"):
		await get_tree().create_timer(0).timeout
	mouse_hovering = true
	while not Input.is_action_pressed("click"):
		await get_tree().create_timer(0).timeout
	if mouse_hovering:
		if get_window().mode == Window.MODE_MAXIMIZED:
			get_window().mode = Window.MODE_WINDOWED
		var start_pos : Vector2 = get_viewport().get_mouse_position()
		var last_mouse_pos : Vector2 = get_viewport().get_mouse_position()
		var new_window_pos : Vector2i = get_viewport().get_mouse_position()
		while Input.is_action_pressed("click"):
			var difference : Vector2 = get_viewport().get_mouse_position() - last_mouse_pos
			if ((difference.y > 0 and get_viewport().get_mouse_position().y > start_pos.y) or \
			(difference.y < 0 and get_viewport().get_mouse_position().y < start_pos.y)):
				new_window_pos = DisplayServer.window_get_position() + Vector2i(get_viewport().get_mouse_position() - last_mouse_pos)
				DisplayServer.window_set_position(Vector2i(clamp(new_window_pos.x, 0, DisplayServer.screen_get_size().x), clamp(new_window_pos.y, 0, DisplayServer.screen_get_size().y)))
			last_mouse_pos = get_viewport().get_mouse_position()
			await get_tree().create_timer(0).timeout


func _on_control_mouse_exited() -> void:
	while Input.is_action_pressed("click"):
		await get_tree().create_timer(0).timeout
	mouse_hovering = false
