extends Node3D

signal took_damage(from: Vector3, force: float, at: PhysicalBone3D, part)

@export var TORSO_MDL : Node3D
@export var L_FARM_MDL : Node3D
@export var L_UARM_MDL : Node3D
@export var R_FARM_MDL : Node3D
@export var R_UARM_MDL : Node3D
@export var HEAD_MDL : Node3D
@export var L_LLEG_MDL : Node3D
@export var L_ULEG_MDL : Node3D
@export var R_LLEG_MDL : Node3D
@export var R_ULEG_MDL : Node3D
@export var head : RigidBody3D
@export var right_arm : RigidBody3D
@export var left_arm : RigidBody3D
@export var right_leg : RigidBody3D
@export var left_leg : RigidBody3D


# Hitting different parts of limbs has different sever damage multipliers
func take_damage(from: Vector3 = Vector3.ZERO, force: float = 0.0, at: PhysicalBone3D = null):
	var part = null
	var found = true
	match at.bone_name:
		"armLower.L":
			L_FARM_MDL.hide()
			part = left_arm
		#"armUpper.L":
			#L_FARM_MDL.hide()
		"armLower.R":
			R_FARM_MDL.hide()
			part = right_arm
		#"armUpper.R":
			#R_FARM_MDL.hide()
		"head":
			HEAD_MDL.hide()
			part = head
		"legLower.L":
			L_LLEG_MDL.hide()
			part = left_leg
		#"legUpper.L":
			#L_LLEG_MDL.hide()
		"legLower.R":
			R_LLEG_MDL.hide()
			part = right_leg
		#"legUpper.R":
			#R_LLEG_MDL.hide()
		_:
			found = false
	if found:
		at.collision_layer = 0
		at.collision_mask = 0
	took_damage.emit(from, force, at, part)
