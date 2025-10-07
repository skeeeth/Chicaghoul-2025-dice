extends Face

func use(_source,_target,_count):
	return get_tree().create_timer(0.0).timeout
