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

var unlocked_dice:int = 5

func _ready() -> void:
	for d in dice_roller.dice:
		d.selected.connect(on_die_locked)
	
	for u in targeting.player_parts:
		u.unlocked.connect(on_die_unlock)
		
	button.pressed.connect(on_button_pressed)
		
	$"../End Turn".turn_ended.connect(on_turn_ended)
	
func on_die_locked() ->void:
	unlocked_dice -= 1
	targeting.targeting_active = (unlocked_dice == 0)
	
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
				d.select()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		reroll()

func on_button_pressed():
	reroll()

func on_turn_ended():
	reroll()
	remaining = base_rerolls
