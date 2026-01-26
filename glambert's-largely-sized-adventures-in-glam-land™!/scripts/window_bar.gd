##A custom task-bar node that looks cool and retro.

extends CanvasLayer

class_name WindowBar


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
