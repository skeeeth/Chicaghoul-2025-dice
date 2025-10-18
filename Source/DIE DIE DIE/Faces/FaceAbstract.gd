@abstract
extends Node
class_name Face

@warning_ignore("unused_signal")
signal animation_finished #used in inherited use function

@export var texture:Texture2D
@export var targeting_req:int = 1
@export var uses:int = 1
const _2D_FACE_DISPLAY = preload("uid://ba8l4kymsrm36")

@export_flags("SELF:1","ALLIES:2","ENEMY:4") var targeting_mask = 8
var sound:AudioStreamPlayer

func _ready() -> void:
	for n in get_children():
		if n is AudioStreamPlayer:
			sound = n


@abstract
func use(source:Unit,targets:Array[Unit],pips:int) -> Signal

func texture_side_slam_animation(source:Unit,target:Unit,pips:int) -> Signal:
	var dummy_face:FaceDisplay2D = _2D_FACE_DISPLAY.instantiate()
	dummy_face.visible = true
	dummy_face.set_texture(texture,Vector2(64,64))
	dummy_face.set_pips(pips)
	var side = sign(source.global_position.x - target.global_position.x)
	target.add_child(dummy_face)
	dummy_face.position.x = side * 250
	var slam = create_tween()
	slam.tween_property(dummy_face,"position:x",0,0.2)\
			.set_trans(Tween.TRANS_ELASTIC)\
			.set_ease(Tween.EASE_IN_OUT) #maybe different trans?
	
	slam.tween_callback(dummy_face.queue_free)
	if sound:
		sound.play()
	return slam.finished
	
