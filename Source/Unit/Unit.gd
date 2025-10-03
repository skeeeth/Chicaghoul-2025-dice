extends PanelContainer
class_name Unit

signal used
signal clicked(who:Unit)
signal damage_taken(amount,attacker)
signal unlocked
signal use_animation_finished #no animations yet

var die:Die
var pip_mod:int = 0
var uses_left:int = -1
var targets:Array[Unit]
var targets_req:int = -1
@export var max_hp:int = 8
var current_hp:int

@export var unit_data:LimbData = preload("uid://d2bi4e8nw4j7g")
@onready var dummy_sprite:Sprite2D = $Sprite2D
@onready var slot: PanelContainer = $HBoxContainer/PanelContainer
@onready var hp_bar: ProgressBar = $HBoxContainer/VBoxContainer/ProgressBar
var hover_border:StyleBox = preload("uid://cv1jild5pwpdy")
var default_box:StyleBox = preload("uid://c27aqt620w33a")
var exhausted_box:StyleBox = preload("uid://tfp525ky7uh4")
var targeting_box:StyleBox = preload("uid://nff6qnc6bv1g")
var locked_die_position:Vector2
#set in vp contaniner ready
static var viewport_offset:Vector2

const SELECT_ANIMATION_TIME:float = 0.1

func _ready() -> void:
	die.selected.connect(on_die_selection)
	hp_bar.max_value = max_hp
	current_hp = max_hp
	hp_bar.value = current_hp
#@export var dice_world:Node3D

func take_damage(amount:int,from:Unit):
	damage_taken.emit(amount,from)
	current_hp -= amount
	hp_bar.value = current_hp
	if current_hp <= 0:
		#DIE DIE DIE THIS IS WHERE DEATH HAPPENS
		pass #do nothing for now :3

func use():
	used.emit()
	var face_index = unit_data.types[die.faceup_side]
	var pip_total = unit_data.pips[die.faceup_side] + pip_mod
	
	Faces.directory[face_index].use(
		self, targets, pip_total
	)
	
	targets.clear()
	targets_req = -1
	
	uses_left -= 1
	if uses_left == 0:
		set_style_exhausted()
	else:
		set_style_base()
	
	#TEMP, SHOULD CALL A REAL ANIMATION
	create_tween().tween_callback(use_animation_finished.emit).set_delay(0.1)


func set_style_base():
	add_theme_stylebox_override("panel",default_box)

func set_style_exhausted():
	add_theme_stylebox_override("panel",exhausted_box)
	
func set_style_targeting():
	add_theme_stylebox_override("panel",targeting_box)

func on_die_selection():
	dummy_sprite.visible = true
	var face_type = unit_data.types[die.faceup_side]
	dummy_sprite.texture =  Faces.directory[face_type].texture
	
	var vp_position = die.camera.unproject_position(die.position)\
			+ viewport_offset
	
	dummy_sprite.global_position = vp_position
	locked_die_position = dummy_sprite.position
	
	die.locked = true
	
	uses_left = die.get_face_type().uses
	
	var glide = create_tween()
	glide.tween_property(dummy_sprite,
			"position",slot.position,
			SELECT_ANIMATION_TIME).set_ease(Tween.EASE_IN_OUT)
	
	
func unselect():
	unlocked.emit()
	uses_left = -1
	die.locked = false
	var glide = create_tween()
	glide.tween_property(dummy_sprite,
			"position",locked_die_position,
			SELECT_ANIMATION_TIME).set_ease(Tween.EASE_IN_OUT)
	glide.tween_property(dummy_sprite,"visible",false,0)
	glide.tween_property(die,"visible",true,0)
	glide.tween_property(die,"locked",false,0)

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("lmb"):
		clicked.emit(self)


func _on_mouse_entered() -> void:
	add_theme_stylebox_override("panel",hover_border)


func _on_mouse_exited() -> void:
	if !die.locked:
		set_style_base()
		return
	
	if targets_req > 0:
		set_style_targeting()
		return

	if uses_left > 0:
		set_style_base()
		return
	else:
		set_style_exhausted()
