extends Node
class_name RollControl

@export var dice_roller:DiceRoller
@export var base_rerolls:int = 2
@export var targeting:TargetControl
@export var button:Button

var remaining:int = base_rerolls:
	set(v):
		remaining = v
		button.text = "Reroll (%s/%s)" % [remaining,base_rerolls]
	get:
		return remaining

var unlocked_dice:int = 0

func _ready() -> void:
	for d in dice_roller.dice:
		d.selected.connect(on_die_locked)
	
	for u in targeting.player_parts:
		u.unlocked.connect(on_die_unlock)
		
	button.pressed.connect(on_button_pressed)
		
	$"../End Turn".enemy_finished.connect(on_enemy_turn_ended)
	
func on_die_locked() -> void:
	unlocked_dice -= 1
	targeting.targeting_active = (unlocked_dice == 0)
	#print(unlocked_dice)
	
func on_die_unlock() -> void:
	unlocked_dice += 1
	targeting.targeting_active = (unlocked_dice == 0)

func reroll() -> void:
	if !remaining > 0:
		#error feedback would go here
		return
		
	for d in dice_roller.dice:
		if !d.sleeping:# if any dice are not sleeping
						#dont roll yet
			#error feedback could go here also
			print("dice moving still")
			return
	
	for d in dice_roller.dice:
		if !d.locked:
			dice_roller.roll(d)
	remaining -= 1
	
	if remaining == 0:
		for d in dice_roller.dice:
			if !d.locked:
				d.sleeping_state_changed.connect(d.select,4)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		reroll()

func on_button_pressed():
	reroll()

func on_enemy_turn_ended():
	await get_tree().create_timer(Unit.SELECT_ANIMATION_TIME).timeout
	unlocked_dice = dice_roller.dice.size()
	reroll()
	remaining = base_rerolls
