extends Face


func use(source:Unit,targets:Array[Unit],pips:int) -> Signal:
	targets.front().pip_mod -= pips
	return texture_side_slam_animation(source,targets.front(),pips)
