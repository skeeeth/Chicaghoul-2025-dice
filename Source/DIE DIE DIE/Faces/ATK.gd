extends Face

func use(source:Unit,targets:Array[Unit],count:int):
	await texture_side_slam_animation(source,targets[0],count)
	targets[0].take_damage(count,source)
	return animation_finished
