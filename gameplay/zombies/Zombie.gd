extends CharacterBody3D

@export var ragdoll : PhysicalBoneSimulator3D
@export var zombie_bar : Label3D
@export var center_bone : PhysicalBone3D
@export var speed : float = 1.0

var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var dead = false

var hp := 5

func _ready():
	ragdoll = $Model.find_child("PhysicalBoneSimulator3D", true)
	if not ragdoll:
		printerr("No ragdoll found on %s" % name)
	else:
		center_bone = ragdoll.find_child("* pelvis")
	_update_bar()
	$Poof.emitting = false


func _physics_process(delta):
	if dead: return
	var player = get_tree().get_first_node_in_group("players")
	var aim = player.global_position - global_position
	velocity.x = (aim.normalized().x * speed)
	velocity.z = (aim.normalized().z * speed)
	if not is_on_floor():
		velocity.y -= gravity * delta
	move_and_slide()
	var cheese = player.global_position
	cheese.y = global_position.y
	look_at(cheese)


func take_damage(from: Vector3 = Vector3.ZERO, force: float = 0.0, at: PhysicalBone3D = null, part = null):
	if dead: return
	hp -= 1
	#if at:
		#ragdoll.physical_bones_start_simulation([at.bone_name])
	var dir = (global_position - from).normalized()
	if part:
		#get_parent().add_child(part)
		part.position = at.position
		part.rotation = at.rotation
		part.reparent(get_parent())
		part.owner = part.get_parent()
		part.show()
		part.process_mode = Node.PROCESS_MODE_INHERIT
		part.apply_central_impulse(dir * force)
	_update_bar()
	if hp <= 0:
		ragdoll.physical_bones_start_simulation()
		force = 30
		var bone = center_bone
		if at:
			bone = at
		if bone:
			bone.apply_central_impulse(dir * force)
		else:
			printerr("No valid bone on %s" % get_parent().name)
		_die()


func _update_bar():
	zombie_bar.text = "I have %d HP" % hp


func _die():
	dead = true
	zombie_bar.hide()
	velocity = Vector3.ZERO
	$AnimationPlayer.play("despawn")
	$Poof.emitting = true
	$Poof.one_shot = true

#const SPEED = 5.0
#const JUMP_VELOCITY = 4.5
#
## Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
#
#
#func _physics_process(delta):
	## Add the gravity.
	#if not is_on_floor():
		#velocity.y -= gravity * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	#if direction:
		#velocity.x = direction.x * SPEED
		#velocity.z = direction.z * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
		#velocity.z = move_toward(velocity.z, 0, SPEED)
#
	#move_and_slide()
