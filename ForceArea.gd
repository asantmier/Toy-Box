extends Area3D

@export var force: float

func _physics_process(delta):
	for body in get_overlapping_bodies():
		(body as RigidBody3D).apply_central_force((body.global_position - global_position).normalized() * force)
