extends RigidBody3D
class_name Die

signal selected
signal hovered
signal hover_ended

var is_hovered:bool = false
var locked:bool = false

var faceup_side:int = 5
var camera:Camera3D
@export var dieData:LimbData
const PIP_FRAMES = preload("uid://bmfmor00snwjo")

const directions:Array[Vector3] = [
	Vector3.FORWARD,
	Vector3.LEFT,
	Vector3.UP,
	Vector3.RIGHT,
	Vector3.BACK,
	Vector3.DOWN
]

@onready var face_sprites:Array[Sprite3D] = [$SpriteF, $SpriteL, $SpriteD, $SpriteR, $SpriteB, $SpriteU]

func _ready() -> void:
	set_faces_from_data(dieData)

func set_faces_from_data(data:LimbData):
	for i in range(0,face_sprites.size()):
		var tex = Faces.directory[data.types[i]].texture
		face_sprites[i].texture = tex
		face_sprites[i].pixel_size = 1.0/tex.get_size().x #assumes square texture
		
		var pip_display = AnimatedSprite3D.new()
		pip_display.sprite_frames = PIP_FRAMES
		pip_display.frame = data.pips[i] - 1 
		pip_display.visible = data.pips[i] != 0
		pip_display.speed_scale = 0
		pip_display.axis = face_sprites[i].axis
		pip_display.pixel_size = 0.5 / \
				pip_display.sprite_frames.get_frame_texture(\
				"default",pip_display.frame).get_size().x
	
		##inteded to move to corner but the math is fucked, ill fix later
		#pip_display.position = Vector3(0.25,0.25,0.25)
		#
		#match pip_display.axis:
			#0: #x axis
				#pip_display.position -= (Vector3(0.25,0,0))
			#1: #y axis
				#pip_display.position -= (Vector3(0,0.25,0))
			#2: #z axis
				#pip_display.position -= (Vector3(0,0,0.25))
		
		face_sprites[i].add_child(pip_display)
		
#emitted from physics when dice settles,
# reads face up side at this time
func _on_sleeping_state_changed() -> void:
	var up_trans:Vector3 = Vector3.UP*quaternion
	var min_diff:float = 0
	var side:int = 0
	var checked_side = 0
	for d in directions:
		var diff = (d-up_trans).length()
		if diff > min_diff:
			min_diff = diff
			side = checked_side
		#print(diff)
		checked_side+= 1
	faceup_side = side
	pass # Replace with function body.

func _on_mouse_entered() -> void:
	is_hovered = true
	hovered.emit()

func _on_mouse_exited() -> void:
	is_hovered = false
	hover_ended.emit()
	pass # Replace with function body.

@warning_ignore("unused_parameter")
func _input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("lmb"):
		select()
	#print(event)
	#print(event_position)

func select():
	if locked:
		return
	
	if !sleeping:
		await sleeping_state_changed
	
	selected.emit()
	locked = true
	visible = false
	#freeze = true
	#collision_layer = 0
	#collision_mask = 0
	#
	#var pre = quaternion
	#var diff = camera.position - position
	#var look_target = diff.rotated(camera.position.cross(position).normalized(),position.angle_to(camera.position))
	#look_at(look_target)
	#var target = quaternion# * directions[faceup_side]
	#quaternion = pre
	##var target = camera.quaternion#.inverse()
	#var tween = create_tween()
	#tween.set_parallel()
	#tween.tween_property(self,"quaternion",target,0.2)
	
func get_face_type() -> Face:
	return Faces.directory[dieData.types[faceup_side]]
