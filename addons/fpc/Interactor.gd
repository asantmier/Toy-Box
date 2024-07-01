extends RayCast3D

@export var pull_curve : Curve
@export var pull_max_distance : float = 1.0
@export var breakaway_distance : float = 1.5
@export_flags_3d_physics var grab_layer : int
@export var rotation_sensitivity : float = 0.1
@export var throw_force : float = 1.0

@export var far_reach : float = 2.0
@export var near_reach : float = 1.25
@export var reach_rate : float = 0.1

@export var HOLDER : Node3D
@export var CAMERA : Camera3D

var held: RigidBody3D
var held_layer: int

var scroll : int = 0
var velocity := Vector3.ZERO

var mouse_input := Vector2.ZERO
# DEPRECATED see comment in _grab_item
var collider_queries : Array[PhysicsShapeQueryParameters3D]

var rotating := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _process(delta):
	if held:
		held.position += velocity * delta


func _physics_process(delta):
	rotating = false
	# TODO use E for grabbing and throwing
	# grab on release, then hold inputs would be prioritized over release inputs
	if Input.is_action_just_pressed("grab"):
		if held:
			_release_item()
		elif is_colliding():
			_interact_item()
	if held:
		_move(delta)
		rotating = Input.is_action_pressed("rotate")
		if Input.is_action_pressed("rotate"):
			_rotate(delta)
		if Input.is_action_just_pressed("throw"):
			# TODO we could apply an impulse so that throw velocity is affected
			#   by mass, but linear velocity cannot be set afterwards or it will
			#   negate all forces hitherto applied
			velocity += throw_force * -CAMERA.global_basis.z
			_release_item()


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
			scroll = -1
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
			scroll = 1
	if Input.is_action_pressed("rotate"):
		if event is InputEventMouseMotion:
			mouse_input += event.relative


# TODO rotate axis function where you can select which axis to rotate about
# using a key for precise rotations.
func _rotate(delta):
	var desired_rot = mouse_input * rotation_sensitivity
	held.rotate(CAMERA.global_basis.y, desired_rot.x)
	held.rotate(CAMERA.global_basis.x, desired_rot.y)
	mouse_input = Vector2.ZERO


func _move(delta):
	# Scrolling
	HOLDER.position.z = -clampf(-HOLDER.position.z - reach_rate * scroll, near_reach, far_reach)
	scroll = 0
	# Interpolation and breakaway
	var dir = HOLDER.global_position - held.global_position
	if dir.length() > breakaway_distance:
		_release_item()
	else:
		#held.global_position = HOLDER.global_position
		var old = held.position
		held.move_and_collide(dir * pull_curve.sample(dir.length() / pull_max_distance))
		velocity = (held.position - old) / delta
		held.position = old
		# Uncomment and comment above to enable physics
		#held.linear_velocity = dir * pull_curve.sample(dir.length() / pull_max_distance) * 20
		#held.apply_central_impulse(dir * pull_curve.sample(dir.length() / pull_max_distance))


func _interact_item():
	var targeted = get_collider()
	print(get_collider())
	if targeted is RigidBody3D:
		_grab_item()
	if targeted.has_method("interact"):
		targeted.interact()


# TODO hold E to charge and throw item
func _release_item():
	held.gravity_scale = 1.0
	held.freeze = false # Comment to enable physics
	held.collision_layer = held_layer
	held.linear_velocity = velocity
	held = null


func _grab_item():
	held = get_collider() as RigidBody3D
	held.gravity_scale = 0.0
	held.freeze = true # Comment to enable physics
	held_layer = held.collision_layer
	held.collision_layer = grab_layer
	# Position item in reach
	HOLDER.position.z = -clampf(global_position.distance_to(held.global_position), near_reach, far_reach)
	# Resets
	velocity = Vector3.ZERO
	mouse_input = Vector2.ZERO
	# Get collider data
	# TODO Surprisingly the code works fine without this, but it would be worth
	#   testing if with larger objects it would be better to check for collision
	#   in the destination location.
	#collider_queries.clear()
	#for owner_id in held.get_shape_owners():
		#var owner_transform = held.shape_owner_get_transform(owner_id)
		#var owner_owner = held.shape_owner_get_owner(owner_id)
		#if owner_owner is Node3D:
			#owner_transform = owner_owner.global_transform * owner_transform
		#for shape_id in held.shape_owner_get_shape_count(owner_id):
			#var shape = held.shape_owner_get_shape(owner_id, shape_id)
			#var query = PhysicsShapeQueryParameters3D.new()
			#query.collision_mask = held.collision_mask
			#query.shape = shape
			#query.transform = owner_transform
			#collider_queries.append(query)
