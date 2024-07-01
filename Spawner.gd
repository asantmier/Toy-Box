extends CSGBox3D

@export var item: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("spawn")


func spawn():
	var new_one = item.instantiate()
	get_parent().add_child(new_one)
	new_one.global_position = $CSGCylinder3D/Target.global_position
	
