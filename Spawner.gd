extends CSGBox3D

@export var item: PackedScene
@export var target: Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("spawn")


func spawn():
	var new_one = item.instantiate()
	get_parent().add_child(new_one)
	new_one.global_position = target.global_position
	
