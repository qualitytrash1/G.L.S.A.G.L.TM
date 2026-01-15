extends Node2D

const POINT = preload("uid://v8qfgbxfrh3l")

@onready var polygon: Polygon2D = $Polygon2D
@onready var collision_polygon: CollisionPolygon2D = $StaticBody2D/CollisionPolygon2D
@onready var points_node: Node2D = $Points

var points : Array = []

func _ready() -> void:
	points = polygon.polygon
	update_points()
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("new_point"):
		if not Input.is_action_pressed("click"):
			points.append(get_local_mouse_position())
			update_polygon()
			update_points()
			while Input.is_action_pressed("new_point"):
				points[len(points) - 1] = get_local_mouse_position()
				update_points()
				await get_tree().create_timer(0).timeout
			points[len(points) - 1] = get_local_mouse_position()
			update_points()
			update_polygon()

func point_pressed(point : Node2D) -> void:
	while Input.is_action_pressed("click"):
		point.position = get_local_mouse_position()
		await get_tree().create_timer(0).timeout
	points[point.get_index()] = get_local_mouse_position()
	update_polygon()
	
func update_points() -> void:
	var index : int = 0
	for i in points_node.get_children():
		if index >= len(points):
			i.queue_free()
			index += 1
			continue
		i.position = points[index]
		index += 1
	if index >= len(points):
		return
	for i in range(index, len(points)):
		var new_point = POINT.instantiate()
		points_node.add_child(new_point)
		new_point.position = points[i]
		index += 1

func update_polygon() -> void:
	polygon.polygon = points
	polygon.uv = points
	collision_polygon.polygon = points
