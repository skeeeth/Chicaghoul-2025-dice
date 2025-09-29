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
			
			#determine if target is valid
			var relationship:int #as Face targeting bit
			if unit == p:#if targeter is target,
				relationship = 1 #targeting self
			elif player_parts.has(unit): #if target is an ally
				relationship = 2 #target is an ally
			else: #if neither
				relationship = 4 #target is enemy
			
			#if targeting relationship is not in the targeting mask
			# abort
			if !p.die.get_face_type().targeting_mask & relationship:
				print("invalid target")
				return
			
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
