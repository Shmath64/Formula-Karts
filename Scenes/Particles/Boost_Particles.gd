extends CPUParticles2D

func _process(delta: float) -> void:
	if get_parent().speed >= get_parent().max_driving_speed + get_parent().boost_strength_speed/2:
		emitting = true
	else:
		emitting = false
