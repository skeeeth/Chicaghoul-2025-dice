extends Face
class_name SpecialActionFace
#man idk if  ts is a good archetcure but whatever

@export var code:int# coupled with listener :/
 
func use(_source:Unit,targets:Array[Unit],_pips:int) -> Signal:
	targets[0].special_action_code.emit(code)
	return texture_side_slam_animation(_source,targets[0],_pips)
