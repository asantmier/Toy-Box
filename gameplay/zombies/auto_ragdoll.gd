extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Armature/Skeleton3D/PhysicalBoneSimulator3D.physical_bones_start_simulation()
