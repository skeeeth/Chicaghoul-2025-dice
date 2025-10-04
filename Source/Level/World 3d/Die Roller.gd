extends Node3D
class_name DiceRoller

@export var initial_die_count:int = 5
@export var xz_range:float = 3
@export var y_range:float = 1.0
const DIE_SCENE:PackedScene = preload("res://Source/DIE DIE DIE/Die Class/Die.tscn")
var dice:Array[Die]
@export var cam:Camera3D
@export var units:Array[Unit]

func _ready() -> void:
	for i in range(0,initial_die_count):
		var new_die:Die = DIE_SCENE.instantiate()
		dice.append(new_die)
		new_die.camera = cam
		add_child(new_die)
	
	for i in range(0,units.size()):
		units[i].die = dice[i]
		dice[i].dieData = units[i].unit_data
	#freeze_and_float_dice()
	#roll()

func freeze_and_float_dice():
	for new_die in dice:
		new_die.position.x = randf_range(-xz_range,xz_range)
		new_die.position.z = randf_range(-xz_range,xz_range)
		new_die.position.y = randf() * y_range
		#new_die.freeze = true
		#new_die.visible = false

func _physics_process(_delta: float) -> void:
	var lr:float = Input.get_axis("ui_left","ui_right")
	if lr:
		for d in dice:
			d.apply_central_force(Vector3.LEFT * lr * 5)

	var ud:float = Input.get_axis("ui_up","ui_down")
	if ud:
		for d in dice:
			d.apply_central_force(Vector3.FORWARD * ud * 5)

func roll(die:Die):
	die.freeze = false
	die.collision_layer = 1
	die.collision_mask = 1
	var popup = create_tween()
	popup.set_parallel()
	popup.tween_method(die.apply_central_force,
			Vector3((randf()-0.5)*3,30,(randf()-0.5)*3) * randf_range(0.7,1),
			Vector3.ZERO,0.7)
	#d.apply_force(Vector3.UP * (20)) 
	popup.tween_method(die.apply_torque,
			Vector3(randf(),randf(),randf())*5,
			Vector3.ZERO,0.3).set_delay(0.1)
