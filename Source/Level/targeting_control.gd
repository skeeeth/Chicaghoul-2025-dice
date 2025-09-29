extends Node

@onready var player_parts:Array[Unit] = [
		$"../Head", $"../ArmL", $"../ArmR", $"../LegL", $"../LegR"]

func _ready() -> void:
	for u in player_parts:
		u.clicked.connect(on_unit_clicked)

func on_unit_clicked(unit:Unit):
	for p in player_parts:
		#if a unit is already trying to target,
		#  it will have a target req over 0
		if p.targets_req > 0:
			p.targets_req -= 1
			p.targets.append(unit)
			if p.targets_req == 0: #activate when all targets are used
				p.use()
			#targeter is found so we can leave now
			return
	
	#if no units are currently targeting, a player can begin targeting
	if !player_parts.has(unit):
		return
	
	unit.targets_req = unit.die.get_face_type().targeting_req
