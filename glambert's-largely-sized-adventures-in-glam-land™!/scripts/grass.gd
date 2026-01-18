@tool

extends Node2D

@export var texture : Texture2D
@export var update : bool = false
@onready var side: Node2D = $Side
@onready var polygon: Polygon2D = $".."
@onready var level: Level = $"../../../../"
@onready var sides: Node2D = $Sides
@onready var textures: Control = $Side/Textures


func _ready() -> void:
	_update()

func _process(delta: float) -> void:
	if update:
		create_tex()
		update = false

func _update() -> void:
	await get_tree().create_timer(0.1).timeout
	create_tex()
	for i in sides.get_children():
		i.queue_free()
	side.hide()
	position = Vector2(0,0)
	var index : int = 0
	for point in polygon.polygon:
		var new_side : Node2D = side.duplicate()
		sides.add_child(new_side)
		var next_point : Vector2
		if index + 1 >= len(polygon.polygon):
			next_point = polygon.polygon[0]
		else:
			next_point = polygon.polygon[index + 1]
		new_side.position = point
		new_side.look_at(next_point + global_position)
		new_side.get_child(0).rotation = new_side.rotation
		new_side.rotation = 0
		var tex_index : float = 0
		for i in new_side.get_child(0).get_children():
			i.size.x = point.distance_to(next_point) - tex_index
			i.get_child(0).size.x = i.size.x
			tex_index += 1
		new_side.show()
		index += 1
		
func create_tex() -> void:
	for i in get_child(0).get_child(0).get_children():
		i.queue_free()
		print("clearing: " + str(i))
	for i in range(texture.get_size().y):
		var new_cont : Control = Control.new()
		get_child(0).get_child(0).add_child(new_cont)
		var new_rect : TextureRect = TextureRect.new()
		new_rect.texture = texture
		new_cont.add_child(new_rect)
		new_cont.size = Vector2(texture.get_size().x, 1)
		new_rect.size = Vector2(texture.get_size().x, i + 1)
		new_cont.clip_contents = true
		new_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		new_rect.stretch_mode = TextureRect.STRETCH_TILE
		new_cont.position.y = i
		new_rect.position.y = -i
		print("added: " + str(new_cont))
		print("added: " + str(new_rect))
	
