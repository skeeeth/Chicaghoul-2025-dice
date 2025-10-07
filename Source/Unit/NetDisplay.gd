#places face displays over all texture rects in die display
#i need the textures in a
extends PanelContainer
class_name  DieDisplay

@export var texture_rects:Array[TextureRect]
const _2D_FACE_DISPLAY = preload("uid://ba8l4kymsrm36")
var face_displays:Array[FaceDisplay2D]

func _ready() -> void:
	for n in texture_rects:
		var new_face_display:FaceDisplay2D = _2D_FACE_DISPLAY.instantiate()
		face_displays.append(new_face_display)
		n.add_child(new_face_display)

func set_display(data:LimbData):
	for i in range(0,face_displays.size()):
		var tex = Faces.directory[data.types[i]].texture
		face_displays[i].set_texture(
			tex,
			texture_rects[i].size)
		face_displays[i].set_pips(data.pips[i])
		texture_rects[i].texture = tex
		print(texture_rects[i].size)
