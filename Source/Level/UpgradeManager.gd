## Handles detecting clean cuts in enemy parts
## and pausing combat to allow possible replacments
## of eligible parts
extends Node2D
class_name upgrade_manager
@export var enemy_manager:EnemyManager
@export var player_parts:Array[Unit]

func _ready() -> void:
	enemy_manager.enemy_spawned.connect(on_new_enemy)
	
func on_part_clean_cut(unit:Unit):
	if unit.type > 0:
		for p_u in player_parts:
			var mask:int
			mask = p_u.type & unit.type
			if mask > 0:
				#cut part and player part share a type
				#so player part can be replaced
				print("shared  type")
				print("Mask: %s" % mask)
				unit.z_index += 2
 
func on_new_enemy(enemy:Enemy):
	for u in enemy.parts:
		u.clean_cut.connect(on_part_clean_cut)
