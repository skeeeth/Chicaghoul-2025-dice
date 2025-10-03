extends Button
class_name TurnManager

signal turn_ended
signal enemy_finished
@export var enemy_manager:EnemyManager
@export var player_control:TargetControl

func _ready() -> void:
	enemy_manager.enemy_turn_finished.connect(on_enemy_finished)

func _on_pressed() -> void:
	
	#dont let turn end if player hasn't used all uses
	var all_used:bool = true
	for u in player_control.player_parts:
		if u.uses_left != 0:
			all_used = false
			var wiggle = create_tween()
			var wiggle_size = 10
			var base = u.position.x
			while abs(wiggle_size) > 0:
				wiggle.tween_property(u,"position:x",base+wiggle_size,0.05)
				wiggle_size *= -1
				wiggle_size += sign(wiggle_size) * -2
			wiggle.tween_property(u,"position:x",base,0.1)
			
	if all_used:
		turn_ended.emit()
	pass # Replace with function body.

func on_enemy_finished():
	enemy_finished.emit()
