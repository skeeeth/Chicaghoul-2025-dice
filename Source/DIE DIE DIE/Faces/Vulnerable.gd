extends Face

var vulnerable_token = preload("uid://dv3tb87qe4ph8")
func use(source:Unit,targets:Array[Unit],pips:int) -> Signal:
	targets[0].add_token(vulnerable_token,source)
	return texture_side_slam_animation(source,targets.front(),pips)
