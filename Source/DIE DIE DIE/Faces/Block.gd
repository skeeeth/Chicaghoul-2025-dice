extends Face

func use(source,targets:Array[Unit],count):
	await  texture_side_slam_animation(source,targets[0],count)
	targets[0].apply_block(count,source)
	return animation_finished
