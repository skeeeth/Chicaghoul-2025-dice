extends Node2D
@export var dice_world:DiceRoller
@export var turn_manager:TurnManager
@export var player_targeting_control:TargetControl

func _ready() -> void:
	spawn_enemy(load("res://Source/Unit/Enemy/Instances/Placeholder/placeholder.tscn"))

func spawn_enemy(scene:PackedScene):
	var new_enemy:Enemy = scene.instantiate()
	new_enemy.pre_ready_setup()
	for d in new_enemy.dice:
		dice_world.add_child(d)
	add_child(new_enemy)
	new_enemy.dice_roller = dice_world
	new_enemy.enemy_target_pool = dice_world.units
	new_enemy.roll()
	turn_manager.turn_ended.connect(new_enemy.take_turn)
	for u in new_enemy.parts:
		u.clicked.connect(player_targeting_control.on_unit_clicked)
