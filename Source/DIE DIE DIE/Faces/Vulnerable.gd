extends Face

func use(source:Unit,targets:Array[Unit],pips:int) -> Signal:
	
	return texture_side_slam_animation(source,targets.front(),pips)
