extends Node3D

@export var item: PackedScene
@export var target: Node3D

var spawn_area : Vector3
var origin : Vector3


func _ready():
	spawn_area = $CollisionShape3D.shape.size
	origin = $CollisionShape3D.global_position - (spawn_area / 2.0)


func spawn():
	var new_one = item.instantiate()
	get_parent().add_child(new_one)
	var x = randf_range(-spawn_area.x / 2, spawn_area.x / 2)
	var z = randf_range(-spawn_area.z / 2, spawn_area.z / 2)
	new_one.global_position = Vector3(x, 0, z) + global_position


func _on_timer_timeout():
	spawn()
