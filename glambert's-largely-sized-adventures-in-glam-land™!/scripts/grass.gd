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


func _ready() -> void:
	_update()

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
	await get_tree().create_timer(0.1).timeout
	_create_tex()
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
	for i in range(texture.get_size().y):
		var new_cont : Control = Control.new()
		get_child(0).get_child(0).add_child(new_cont)
		var new_rect : TextureRect = TextureRect.new()
		new_rect.texture = texture
		new_rect.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
		new_cont.add_child(new_rect)
		new_cont.scale = Vector2(1, 1) / get_child(0).get_child(0).scale
		new_rect.scale = new_cont.scale
		new_cont.size = Vector2(texture.get_size().x, 1)
		new_rect.size = Vector2(texture.get_size().x, i + 1)
		new_cont.clip_contents = true
		new_rect.stretch_mode = TextureRect.STRETCH_TILE
		new_cont.position.y = i
		new_rect.position.y = -i
		new_cont.size.x += float(i) / 4.0
		new_cont.position.x += float(i) / 8.0
		new_rect.size.x = new_cont.size.x
		new_rect.position.x = new_cont.position.x
		print("added: " + str(new_cont))
		print("added: " + str(new_rect))
