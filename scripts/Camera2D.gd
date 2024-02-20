extends Camera2D

var target = null

func _physics_process(_delta: float) -> void:
	if target:
		position = Vector2(target.position.x,target.position.y)
