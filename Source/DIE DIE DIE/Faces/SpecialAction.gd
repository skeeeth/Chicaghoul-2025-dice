extends Face
class_name SpecialActionFace
##Emits a signal in the user to perform some kind of action
##should be used for actions that require data about the user
##ex: spawn an enemy, because a this face should NOT be able
## to reference the state or enemy its called from

#man idk if ts is a good archetcure but whatever

#@export var code:int# coupled with listener :/
 
func use(source:Unit,targets:Array[Unit],pips:int) -> Signal:
	targets[0].special_action_code.emit(pips)
	return texture_side_slam_animation(source,targets[0],pips)
