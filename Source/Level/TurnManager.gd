extends Button
class_name TurnManager

signal turn_ended




func _on_pressed() -> void:
	turn_ended.emit()
	pass # Replace with function body.
