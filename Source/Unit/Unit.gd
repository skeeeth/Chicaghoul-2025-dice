## DOIN WAAY TOO MUCH, 
## should be refactored into a couple parts
## but right now handles: hp, die locking/usage AND visuals

extends Control
class_name Unit

signal used
signal clicked(who:Unit)
signal damage_taken(amount,attacker)
signal death(reference)
signal unlocked
signal use_animation_finished #no animations yet
signal clean_cut(reference:Unit)

var die:Die
var pip_mod:int = 0:
	set(v):
		pip_mod = v
		if die:
			face_display.set_pips(unit_data.pips[die.faceup_side] + pip_mod)
	get:
		return pip_mod
var uses_left:int = -1
var targets:Array[Unit]
var targets_req:int = -1
var current_hp:int

@export_category("Stats")
@export_flags("Head:1","Arm:2","Leg:4") var type = 8
@export var max_hp:int = 0
@export var unit_data:LimbData = preload("uid://d2bi4e8nw4j7g")
@export_category("Nodes")
@export var face_display:FaceDisplay2D
@export var sprite:Sprite2D
@export var die_display:DieDisplay

@onready var slot: PanelContainer = %FaceSlot
@onready var hp_bar: ProgressBar = %HpBar
@onready var name_line: Label = %NameLine
@onready var token_container: HBoxContainer = %"Token Container"


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
	name_line.text = name
	set_data(unit_data)
#@export var dice_world:Node3D

func take_damage(amount:int,from:Unit):
	damage_taken.emit(amount,from)
	current_hp -= amount
	hp_bar.value = current_hp
	if current_hp <= 0:
		on_death(abs(current_hp))

func use():
	used.emit()
	var face_index = unit_data.types[die.faceup_side]
	var pip_total = unit_data.pips[die.faceup_side] + pip_mod
	
	await Faces.directory[face_index].use(
		self, targets, pip_total
	)
	
	targets.clear()
	targets_req = -1
	
	uses_left -= 1
	if uses_left == 0:
		set_style_exhausted()
	else:
		set_style_base()
	use_animation_finished.emit()

func set_style_base():
	add_theme_stylebox_override("panel",default_box)

func set_style_exhausted():
	add_theme_stylebox_override("panel",exhausted_box)
	
func set_style_targeting():
	add_theme_stylebox_override("panel",targeting_box)

func on_die_selection():
	face_display.visible = true
	#var face_type = unit_data.types[die.faceup_side]
	#face_display.face_texture.texture =  die.get_face_type().texture
	face_display.set_texture(#HARDCODED SIZE HAS NEVER CAUSED AN ISSUE
			die.get_face_type().texture,Vector2(64,64))
	
	face_display.pip_display.frame = \
			unit_data.pips[die.faceup_side] - 1
	
	var vp_position = die.camera.unproject_position(
			die.position)\
			+ viewport_offset
	
	face_display.global_position = vp_position

	locked_die_position = face_display.position
	
	die.locked = true
	
	uses_left = die.get_face_type().uses
	
	var glide = create_tween()
	glide.tween_property(face_display,#STINKY HARDCODED OFFSET VVVV
			"global_position",slot.global_position + Vector2(32.5,32), 
			SELECT_ANIMATION_TIME).set_ease(Tween.EASE_IN_OUT)
	
	
func unselect():
	if !die.locked:
		return
	print("%s, %s" % [die.faceup_side,unit_data.pips[die.faceup_side]])
	unlocked.emit()
	uses_left = -1
	die.locked = false
	var glide = create_tween()
	glide.tween_property(face_display,
			"position",locked_die_position,
			SELECT_ANIMATION_TIME).set_ease(Tween.EASE_IN_OUT)
	glide.tween_property(face_display,"visible",false,0)
	glide.tween_property(die,"visible",true,0)
	glide.tween_property(die,"locked",false,0)

func on_death(overkill:int):
	var fade = create_tween()
	fade.set_parallel()
	if sprite:
		fade.tween_property(sprite,"modulate:a",0,1)
	fade.tween_property(self,"modulate:a",0,1)
	death.emit(self)
	
	if overkill == 0:
		#clean cut, should activate replacement
		clean_cut.emit(self)
		pass


func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("lmb"):
		clicked.emit(self)
	if event.is_action_pressed("rmb"):
		die_display.visible = !die_display.visible


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

func set_data(data:LimbData):
	die.dieData = data
	die.set_faces_from_data(data)
	unit_data = data
	if sprite:
		sprite.texture = data.texture
	die_display.set_display(data)

func add_token(token_type:PackedScene,source:Unit):
	var new_token:StatusToken = token_type.instantiate()
	token_type.apply(source,self)
	
