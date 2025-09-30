extends Node2D

var parts:Array[Unit]
#TEMP HACK FOR NOW

func _ready() -> void:
	$"../Node/Head".die =$"../Node/Head/RigidBody3D"
	
