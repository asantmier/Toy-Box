extends CSGCombiner3D

@export var label: Label3D

var score: int

# Called when the node enters the scene tree for the first time.
func _ready():
	score = 0
	label.text = str(score)


func _on_area_body_entered(body):
	score += 1
	label.text = str(score)
