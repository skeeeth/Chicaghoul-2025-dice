extends SubViewportContainer

@export var viewport:Viewport

func _ready() -> void:
	viewport.set_process_input(true)

func _unhandled_input(event: InputEvent) -> void:
	viewport.push_input(event)
