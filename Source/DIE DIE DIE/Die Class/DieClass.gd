extends RigidBody3D
class_name Die

signal selected

var hovered:bool = false
var locked:bool = false

var faceup_side:int = 5
var camera:Camera3D
@export var spriteData:LimbData


const directions:Array[Vector3] = [
	Vector3.FORWARD,
	Vector3.LEFT,
	Vector3.DOWN,
	Vector3.RIGHT,
	Vector3.BACK,
	Vector3.UP
]

@onready var face_sprites:Array[Sprite3D] = [$SpriteF, $SpriteL, $SpriteD, $SpriteR, $SpriteB, $SpriteU]

func _ready() -> void:
	set_faces_from_data(spriteData)

func set_faces_from_data(data:LimbData):
	for i in range(0,face_sprites.size()):
		face_sprites[i].texture = Faces.directory[data.types[i]].texture

#emitted from physics when dice settles,
# reads face up side at this time
func _on_sleeping_state_changed() -> void:
	var up_trans:Vector3 = Vector3.UP*quaternion
	var min_diff:float = 999
	var side:int = 0
	var checked_side = 0
	for d in directions:
		var diff = (d-up_trans).length()
		if diff < min_diff:
			min_diff = diff
			side = checked_side
		#print(diff)
		checked_side+= 1
	
	pass # Replace with function body.

func _on_mouse_entered() -> void:
	hovered = true

func _on_mouse_exited() -> void:
	hovered = false
	pass # Replace with function body.

func _input_event(_camera: Camera3D, event: InputEvent, event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event.is_action_pressed("lmb"):
		select()
	#print(event)
	#print(event_position)

func select():
	selected.emit()
	locked = true
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
	
	
