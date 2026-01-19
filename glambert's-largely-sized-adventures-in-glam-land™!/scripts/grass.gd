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

var thread : Thread = Thread.new()


func _ready() -> void:
	if thread.is_started():
		thread.wait_to_finish()
	thread = Thread.new()
	thread.start(_update)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		if update:
			level.update_polygons()
			_update()
			update = false
		if create_tex:
			_create_tex()
			create_tex = false

func _update() -> void:
	await get_tree().create_timer(0).timeout
	call_deferred("_create_tex")
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
		tex_polygon.polygon[2].x = tex_polygon.global_position.distance_to(next_point + global_position) - 16
		tex_polygon.polygon[3].x = 16
		new_side.show()
		index += 1
		
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
