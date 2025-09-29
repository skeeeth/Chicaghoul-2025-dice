@abstract
extends Node
class_name Face

@export var texture:Texture2D
@export var targeting_req:int = 1

@abstract
func use(source:Unit,targets:Array[Unit],pips:int)
