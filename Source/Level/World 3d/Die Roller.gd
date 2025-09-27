extends Node3D
@export var initial_die_count:int = 5
@export var xz_range:float = 3
@export var y_range:float = 1.0
const DIE_SCENE:PackedScene = preload("res://Source/DIE DIE DIE/Die Class/Die.tscn")
var dice:Array[Die]

func _ready() -> void:
	for i in range(0,initial_die_count):
		var new_die:Die = DIE_SCENE.instantiate()
		dice.append(new_die)
		add_child(new_die)
	
	freeze_and_float_dice()
	roll()

func freeze_and_float_dice():
	for new_die in dice:
		new_die.position.x = randf_range(-xz_range,xz_range)
		new_die.position.z = randf_range(-xz_range,xz_range)
		new_die.position.y = randf() * y_range
		#new_die.freeze = true
		#new_die.visible = false
		
func roll():
	for d in dice:
		var popup = create_tween()
		popup.set_parallel()
		popup.tween_method(d.apply_central_force,
				Vector3.UP * 40 * randf_range(0.7,1),
				Vector3.ZERO,0.7)
		#d.apply_force(Vector3.UP * (20)) 
		popup.tween_method(d.apply_torque,
				Vector3(randf(),randf(),randf())*5,
				Vector3.ZERO,0.3).set_delay(0.1)
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		roll()
