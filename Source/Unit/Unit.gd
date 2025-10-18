## DOIN WAAY TOO MUCH, 
## should be refactored into a couple parts
## but right now handles: hp, die locking/usage AND visuals

extends Control
class_name Unit

signal used
signal clicked(who:Unit)
signal damage_incoming(amount)
signal damage_taken(amount,attacker)
signal block_incoming(amount:int,source:Unit)
signal death(reference)
signal unlocked
signal use_animation_finished #no animations yet
signal clean_cut(reference:Unit)
@warning_ignore("unused_signal")
signal special_action_code(code:int) #called on face

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
var current_hp:int:
	set(v):
		current_hp = v
		hp_bar.value = current_hp
		hp_label.text = "%s/%s" % [current_hp,max_hp]
	get:
		return current_hp

var incoming_mod:int = 0
var block:int = 0:
	set(v):
		block = v
		_block_display.visible = block > 0
		block_label.text = str(block)
	get:
		return block

@export_category("Stats")
@export_flags("Head:1","Arm:2","Leg:4") var type = 8
@export var max_hp:int = 9
@export var unit_data:LimbData = preload("uid://d2bi4e8nw4j7g")
@export_category("Nodes")
@export var face_display:FaceDisplay2D
@export var sprite:Sprite2D
@export var die_display:DieDisplay
@export var _block_display:Node2D
@export var block_label:Label
@export var hp_label:Label

@onready var slot: PanelContainer = %FaceSlot
@onready var hp_bar: ProgressBar = %HpBar
@onready var name_line: Label = %NameLine
@onready var token_container: HBoxContainer = %"Token Container"
@onready var panel: PanelContainer = %Panel


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
	var total_damage = amount
	#notify modifiers
	damage_incoming.emit(amount)
	total_damage += incoming_mod #apply modifiers
	
	var health_loss = total_damage - block
	health_loss = max(health_loss,0) #if block is > damage, take zero
	current_hp -= health_loss

	damage_taken.emit(total_damage,from)
	incoming_mod = 0 #reset
	if current_hp <= 0:
		on_death(abs(current_hp))

func apply_block(amount:int,from:Unit):
	block_incoming.emit(amount,from)
	amount += incoming_mod
	block += amount
	incoming_mod = 0

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
	panel.add_theme_stylebox_override("panel",default_box)

func set_style_exhausted():
	panel.add_theme_stylebox_override("panel",exhausted_box)
	
func set_style_targeting():
	panel.add_theme_stylebox_override("panel",targeting_box)

func on_die_selection():
	face_display.visible = true
	#var face_type = unit_data.types[die.faceup_side]
	#face_display.face_texture.texture =  die.get_face_type().texture
	face_display.set_texture(#HARDCODED SIZE HAS NEVER CAUSED AN ISSUE
			die.get_face_type().texture,Vector2(64,64))
	
	face_display.set_pips(
		unit_data.pips[die.faceup_side] + pip_mod)
	
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

	##DEBUG DEV INPUT
	if event.is_action_pressed("mmb"):
		clean_cut.emit(self)


func _on_mouse_entered() -> void:
	panel.add_theme_stylebox_override("panel",hover_border)

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
	new_token.apply(source,self)
	

func on_enemy_turn_end():
	block = 0
	
