extends Node2D
class_name Enemy

signal finished

const DIE_SCENE:PackedScene = preload("res://Source/DIE DIE DIE/Die Class/Die.tscn")
var parts:Array[Unit]
var dice:Array[Die]
var enemy_target_pool:Array[Unit]

var dice_roller:DiceRoller
var live_dice:int = 0
#called before being added to scene tree
#finds all children and gives them dice
func pre_ready_setup():
	for n in get_children():
		if n is Unit:
			parts.append(n)
	
	for u in parts:
		var new_die:Die = DIE_SCENE.instantiate()
		new_die.set_faces_from_data(u.unit_data)
		u.die = new_die
		new_die.collision_layer = 2
		new_die.collision_mask = 2
		new_die.sleeping_state_changed.connect(on_die_settled)
		dice.append(new_die)

func take_turn():
	for u in parts:
		u.use()
		await u.use_animation_finished
		u.unselect()
	roll()


func roll():
	for d in dice:
		dice_roller.roll(d)
	
	#on_dice_settled assumes dice are only entering sleep,
	# not waking up, so we have to set the number
	# of live dice shortly after rolling starts
	await get_tree().create_timer(0.05).timeout
	live_dice = dice.size()


func set_targets():
	for u in parts:
		u.die.select()
		var possible_targets:Array[Unit]
		var mask = u.die.get_face_type().targeting_mask
		
		if mask & 2: #if allies are targetable
			possible_targets.append_array(parts)
			if !mask & 1:
				possible_targets.erase(u)

		if mask & 4: 
			possible_targets.append_array(enemy_target_pool)
		
		u.targets_req = u.die.get_face_type().targeting_req
		while u.targets_req > 0:
			u.targets.append(possible_targets.pick_random())
			u.targets_req -= 1
	finished.emit()
	
func on_die_settled():
	live_dice -= 1
	
	if live_dice == 0:
		set_targets()
	
