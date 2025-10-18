extends Enemy

@export var disable_list:Array[Unit]# = [$"Left Arm", $"Right Arm", $"Left Leg", $"Right Leg"]
@export var torso:Unit

func _ready() -> void:
	for u in disable_list:
		u.die.visible = false
		parts.erase(u)
	torso.special_action_code.connect(on_action_code)

func spawn():
	pass

func on_action_code(code:int):
	#do the thing
	var unit = disable_list[code]
	unit.visible = true
	unit.die.visible = true
	var snap_out = create_tween()
	snap_out.tween_property(unit.sprite,"position",Vector2.ZERO,0.1)
	if !parts.has(unit):
		spawn_list.append(unit)
		
	pass	
