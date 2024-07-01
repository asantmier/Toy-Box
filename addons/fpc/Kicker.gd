extends Area3D

@export var force: float

var tracking: Array[RigidBody3D]
var _last_pos := Vector3.ZERO

func _physics_process(delta):
	if not is_zero_approx((global_position - _last_pos).length_squared()):
		for body in tracking:
			body.apply_central_impulse((body.global_position - global_position).normalized() * force)
			tracking.erase(body)
	_last_pos = global_position


func _on_body_entered(body):
	tracking.append(body as RigidBody3D)
	(body as RigidBody3D).linear_velocity = Vector3.ZERO
	(body as RigidBody3D).angular_velocity = Vector3.ZERO


func _on_body_exited(body):
	tracking.erase(body as RigidBody3D)
