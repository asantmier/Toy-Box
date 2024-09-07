extends RayCast3D

enum {OFF, BUILD}

var mode := OFF

var prop = preload("res://models/kenney/kenney furniture/bathtub.glb")
@export var holo_material : Material

var _hologram : Node3D

var scroll : int = 0
@export var rotate_speed : float = 0.3

# Called when the node enters the scene tree for the first time.
func _ready():
	_hologram = prop.instantiate()
	for child in _hologram.get_children():
		if child is MeshInstance3D:
			for i in range(child.get_surface_override_material_count()):
				child.set_surface_override_material(i, holo_material)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("build_selected"):
		if mode == BUILD and is_colliding():
			var point = get_collision_point()
			var summon = prop.instantiate()
			get_collider().add_child(summon)
			summon.global_transform = _hologram.global_transform
			print("summoned")
	
	if Input.is_action_just_pressed("build_mode"):
		if mode == OFF:
			_goto_build()
		elif mode == BUILD:
			_exit_build()
		print(mode)
	
	if mode == BUILD:
		if is_colliding():
			var point = get_collision_point()
			var norm = get_collision_normal()
			_hologram.global_position = point
			# If you don't do this scale thing weird things happen
			var tmp = _hologram.scale
			_hologram.global_basis = align_up(_hologram.global_basis, norm)
			_hologram.scale = tmp
			_hologram.rotate_y(rotate_speed * scroll)
			scroll = 0


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_UP):
			scroll = -1
		elif Input.is_mouse_button_pressed(MOUSE_BUTTON_WHEEL_DOWN):
			scroll = 1


# I think this is basically https://kidscancode.org/godot_recipes/3.x/3d/3d_align_surface/index.html
func align_up(basis, up):
	basis.y = up
	basis.x = -basis.z.cross(up)
	basis = basis.orthonormalized()
	return basis


func _goto_build():
	mode = BUILD
	_hologram.top_level = true
	add_child(_hologram)


func _exit_build():
	mode = OFF
	if _hologram.get_parent():
		_hologram.get_parent().remove_child(_hologram)
	
