extends PanelContainer
class_name Unit

signal used
signal clicked(who:Unit)
signal damage_taken(amount,attacker)


var die:Die
var pip_mod:int = 0
var use_type:int = 2
var targets:Array[Unit]
var targets_req:int = -1
@export var max_hp:int = 8
var current_hp:int

@export var unit_data:LimbData = preload("res://Source/DIE DIE DIE/Types/Default.tres")
@onready var dummy_sprite:Sprite2D = $Sprite2D
@onready var slot: PanelContainer = $HBoxContainer/PanelContainer
@onready var hp_bar: ProgressBar = $HBoxContainer/VBoxContainer/ProgressBar
var hover_border:StyleBox = preload("uid://cv1jild5pwpdy")
var default_box:StyleBox = preload("uid://c27aqt620w33a")

var locked_die_position:Vector3
#set in vp contaniner ready
static var viewport_offset:Vector2

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
	set_style_base()

func set_style_base():
	add_theme_stylebox_override("panel",default_box)

func on_die_selection():
	dummy_sprite.visible = true
	var face_type = unit_data.types[die.faceup_side]
	dummy_sprite.texture =  Faces.directory[face_type].texture
	
	dummy_sprite.global_position = \
			die.camera.unproject_position(die.position)\
			+ viewport_offset
	var glide = create_tween()
	glide.tween_property(dummy_sprite,
			"position",slot.position,0.2).set_ease(Tween.EASE_IN_OUT)


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("lmb"):
		clicked.emit(self)


func _on_mouse_entered() -> void:
	add_theme_stylebox_override("panel",hover_border)


func _on_mouse_exited() -> void:
	if targets_req < 0:
		set_style_base()
