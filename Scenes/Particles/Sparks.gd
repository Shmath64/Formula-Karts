extends CPUParticles2D


func _ready() -> void:
	emitting = true
	$Timer.wait_time = lifetime

func _on_Timer_timeout() -> void:
	get_parent().remove_child(self)
