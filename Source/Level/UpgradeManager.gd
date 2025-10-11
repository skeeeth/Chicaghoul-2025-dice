## Handles detecting clean cuts in enemy parts
## and pausing combat to allow possible replacments
## of eligible parts
extends Node2D
class_name upgrade_manager
@export var enemy_manager:EnemyManager
@export var player_parts:Array[Unit]
var cut_data:LimbData
var used:bool = false

func _ready() -> void:
	enemy_manager.enemy_spawned.connect(on_new_enemy)
	enemy_manager.combat_over.connect(on_combat_end)

func on_part_clean_cut(unit:Unit):
	visible = true
	cut_data = unit.unit_data
	if unit.type > 0:
		for p_u in player_parts:
			var mask:int
			mask = p_u.type & (unit.type-8)
			if mask > 0:
				#cut part and player part share a type
				#so player part can be replaced
				print("shared  type")
				print("Mask: %s" % mask)
				p_u.z_index += 2
				p_u.clicked.connect(on_clicked)
 
func on_new_enemy(enemy:Enemy):
	for u in enemy.parts:
		u.clean_cut.connect(on_part_clean_cut)
		

func on_clicked(unit:Unit):
	unit.set_data(cut_data)
	for u in player_parts:
		if u.clicked.is_connected(on_clicked):
			u.clicked.disconnect(on_clicked)
	visible = false
	used = true

func on_combat_end():
	used = false
