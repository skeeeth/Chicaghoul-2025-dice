extends Node2D
class_name FaceDisplay2D

@export var face_texture: Sprite2D 
@export var pip_display: AnimatedSprite2D 

func set_texture(texture:Texture2D,size:Vector2):
	face_texture.scale.x = size.x / texture.get_size().x
	face_texture.scale.y = size.y / texture.get_size().y
	face_texture.texture = texture

func set_pips(pips:int):
	if pips == 0:
		pip_display.visible = false
		return
	pip_display.frame = pips - 1
