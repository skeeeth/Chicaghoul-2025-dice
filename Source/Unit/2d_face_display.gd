extends Node2D
class_name FaceDisplay2D

@export var face_texture: Sprite2D 
@export var pip_display: AnimatedSprite2D 

func set_texture(texture:Texture2D,size:Vector2):
	face_texture.scale.x = size.x / texture.get_size().x
	face_texture.scale.y = size.y / texture.get_size().y
	face_texture.texture = texture

func set_pips(pips:int):
	pip_display.visible = pips != 0
	print(pips != 0)
	if pips == 0:
		return
	pip_display.frame = pips - 1
