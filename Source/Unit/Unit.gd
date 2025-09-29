extends PanelContainer
class_name Unit

signal used

var die:Die
var pip_mod:int = 0
var use_type:int = 2
var target:Unit
@export var unit_data:LimbData = preload("res://Source/DIE DIE DIE/Types/Default.tres")
@onready	 var dummy_sprite:Sprite2D = $Sprite2D
@onready var slot: PanelContainer = $HBoxContainer/PanelContainer

var locked_die_position:Vector3
static var viewport_offset:Vector2

func _ready() -> void:
	die.selected.connect(on_die_selection)
#@export var dice_world:Node3D

func use():
	used.emit()
	var face_index = unit_data.types[die.faceup_side]
	var pip_total = unit_data.pips[die.faceup_side] + pip_mod
	
	Faces.directory[face_index].use(
		self, target, pip_total
	)
	

func on_die_selection():
	dummy_sprite.visible = true
	var face_type = unit_data.types[die.faceup_side]
	dummy_sprite.texture =  Faces.directory[face_type].texture
	
	dummy_sprite.global_position = \
			die.camera.unproject_position(die.position)\
			+ viewport_offset
	var glide = create_tween()
	glide.tween_property(dummy_sprite,
			"position",slot.position,0.2)#.set_ease(Tween.EASE_IN_OUT)
