@tool

extends Node2D

@export var texture : Texture2D
@export var update : bool = false
@export var create_tex : bool = false
@onready var side: Node2D = $Side
@onready var polygon: Polygon2D = $".."
@onready var level: Level = $"../../../../"
@onready var sides: Node2D = $Sides
@onready var textures: Control = $Side/Textures

signal done_making_texture
var texture_ready : bool = false

var thread : Thread

var distances : Array[Vector2] = []


func _ready() -> void:
	_update_threaded()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if update:
			level.update_polygons()
			_update_threaded(true)
			update = false
		if create_tex:
			_create_tex()
			create_tex = false
			
func _update_threaded(debug : bool = false) -> void:
	if thread:
		if thread.is_started():
			thread.wait_to_finish()
	thread = Thread.new()
	thread.start(_update.bind(debug))

func _update(debug : bool = false) -> void:
	#HIDE/QUEUE FREE DEBUG TEXT
	await get_tree().create_timer(0).timeout
	if not debug or Globals.final_export:
		for i in side.get_child(0).get_children():
			if Globals.final_export:
				i.queue_free()
			else:
				i.hide()
	if not debug or Globals.final_export:
		if Globals.final_export:
			side.get_child(1).queue_free()
		else:
			side.get_child(1).hide()
	if debug:
		for i in side.get_child(0).get_children():
			i.show()
		side.get_child(1).show()
	distances = []
	_create_tex()
	if not texture_ready:
		await done_making_texture
	for i in sides.get_children():
		i.queue_free()
	side.hide()
	position = Vector2(0,0)
	var index : int = 0
	for point in polygon.polygon:
		var new_side : Node2D = side.duplicate()
		var tex_polygon : Polygon2D = new_side.get_child(0)
		sides.add_child(new_side)
		var next_point : Vector2
		if index + 1 >= len(polygon.polygon):
			next_point = polygon.polygon[0]
		else:
			next_point = polygon.polygon[index + 1]
		new_side.position = point
		tex_polygon.look_at(next_point + global_position)
		tex_polygon.polygon[0].x = 0
		tex_polygon.polygon[1].x = tex_polygon.global_position.distance_to(next_point + global_position)
		tex_polygon.polygon[2].x = tex_polygon.global_position.distance_to(next_point + global_position)
		tex_polygon.polygon[3].x = 0
		new_side.show()
		#DEBUG
		if debug:
			update_visual_points(tex_polygon)
		index += 1
	await get_tree().create_timer(0).timeout
	index = 0
	for this_side in sides.get_children():
		var tex_polygon : Polygon2D = this_side.get_child(0)
		var next_side : Node2D
		var next_tex_polygon : Polygon2D
		next_side = get_next_side(index)
		next_tex_polygon = next_side.get_child(0)
		var distance : float = abs(tex_polygon.polygon[2].x - next_tex_polygon.polygon[3].x)
		#DEBUG
		if debug:
			this_side.get_child(1).text += str(float(round(distance * 1000)) / 1000.0)
		index += 1
	index = 0
	for this_side in sides.get_children():
		var tex_polygon : Polygon2D = this_side.get_child(0)
		var next_side : Node2D
		var next_tex_polygon : Polygon2D
		next_side = get_next_side(index)
		next_tex_polygon = next_side.get_child(0)
		index += 1
			
func get_next_side(index : int) -> Node2D:
	if index + 1 >= len(polygon.polygon):
		return sides.get_child(0)
	else:
		return sides.get_child(index + 1)
		
func update_visual_points(tex_polygon : Polygon2D) -> void:
	var rand_color : Color = Color.RED
	rand_color.h = (tex_polygon.global_position.distance_to(Vector2(0,0)) / 8)
	var index : int = 0
	for i in tex_polygon.get_children():
		i.position = tex_polygon.polygon[index]
		i.position.y -= 4
		i.rotation = -tex_polygon.rotation
		i.modulate = rand_color
		#i.global_position += Vector2(randf_range(-2,2), randf_range(-2,2))
		index += 1
	tex_polygon.get_parent().get_child(1).text = str(tex_polygon.get_parent().get_index()) + ": [color=#" + str(rand_color.to_html()) + "]"
		
func _create_tex() -> void:
	var tex_polygon : Polygon2D = get_child(0).get_child(0)
	tex_polygon.texture = texture
	tex_polygon.polygon = [
		Vector2(0,0),
		Vector2(16,0),
		Vector2(16,16),
		Vector2(0,16),
	]
	tex_polygon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	tex_polygon.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	emit_signal("done_making_texture")
	texture_ready = true
	
func _exit_tree() -> void:
	thread.wait_to_finish()
	
func _input(event: InputEvent) -> void:
	if not Globals.final_export:
		if event is InputEventKey:
			if Input.is_action_just_pressed("debug_grass"):
				_update_threaded(true)
