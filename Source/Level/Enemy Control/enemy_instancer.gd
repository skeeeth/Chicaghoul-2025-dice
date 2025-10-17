extends Node2D
class_name EnemyManager

signal enemy_turn_finished
signal enemy_spawned(enemy:Enemy)
signal combat_over

@export var dice_world:DiceRoller
@export var turn_manager:TurnManager
@export var player_targeting_control:TargetControl
@export var pool:EnemyPool

func _ready() -> void:
	spawn_enemy(load("res://Source/Unit/Enemy/Instances/Placeholder/placeholder.tscn"))

func spawn_enemy(scene:PackedScene):
	var new_enemy:Enemy = scene.instantiate()
	new_enemy.pre_ready_setup()
	for d in new_enemy.dice:
		dice_world.add_child(d)
		d.camera = dice_world.cam
	add_child(new_enemy)
	new_enemy.dice_roller = dice_world
	new_enemy.enemy_target_pool = dice_world.units
	new_enemy.roll()
	turn_manager.turn_ended.connect(new_enemy.take_turn)
	new_enemy.finished.connect(on_enemy_turn_finished)
	new_enemy.full_death.connect(on_full_death)
	for u in new_enemy.parts:
		u.clicked.connect(player_targeting_control.on_unit_clicked)
	
	enemy_spawned.emit.call_deferred(new_enemy)

#propagate up
func on_enemy_turn_finished():
	enemy_turn_finished.emit()

func on_full_death():
	combat_over.emit()
	spawn_enemy(pool.sequence.front())
	
