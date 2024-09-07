extends RayCast3D

@export var fire_rate := 0.120
var _time_acc := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	_time_acc = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_time_acc += delta
	if Input.is_action_just_pressed("attack"):
		attack()
	elif Input.is_action_pressed("attack"):
		if _time_acc >= fire_rate:
			attack()


func find_parent_damageable(targeted):
	if targeted.has_method("take_damage"):
		return targeted
	var retarget = targeted
	var depth = 0
	while retarget.owner and depth < 2:
		retarget = retarget.owner
		depth += 1
		if retarget.has_method("take_damage"):
			return retarget
	return null


func attack():
	_time_acc = 0.0
	if is_colliding():
		var targeted := get_collider() as Node3D
		print(get_collider())
		if targeted.has_method("take_damage"):
			targeted.take_damage(global_position)
		else:
			var parented = find_parent_damageable(targeted)
			if parented:
				parented.take_damage(global_position, 20, targeted)
		var decal = preload("res://gameplay/guns/decal.tscn").instantiate()
		targeted.add_child(decal)
		decal.global_basis = align_up(decal.global_basis, get_collision_normal())
		#decal.scale = Vector3.ONE
		decal.global_position = get_collision_point()
		decal.size = Vector3.ONE * 0.30
		#DebugDraw3D.draw_box(decal.global_position, decal.global_basis.get_rotation_quaternion(), decal.size, Color.RED, true, 10)
		#DebugDraw3D.draw_arrow(decal.global_position, decal.global_position + decal.global_basis.y, Color.PINK, .1, true, 10)


func align_up(basis, up):
	# Adapted from https://kidscancode.org/godot_recipes/3.x/3d/3d_align_surface/index.html
	# The above method does not work if the target y is parallel to the basis axes.
	# Randomizes basis before aligning to avoid axis lock, fixing this problem.
	# This has the added bonus of randomly rotating the decal
	var rand_b = Quaternion.from_euler(Vector3(randf() * 360, randf() * 360, randf() * 360).normalized())
	basis = Basis(rand_b)
	basis.y = up
	basis.x = -basis.z.cross(up)
	basis = basis.orthonormalized()
	return basis
