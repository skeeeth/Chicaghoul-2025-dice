@abstract
extends Node
class_name Face

@export var texture:Texture2D
@export var targeting_req:int = 1
@export var uses:int = 1

@export_flags("SELF:1","ALLIES:2","ENEMY:4") var targeting_mask = 8

@abstract
func use(source:Unit,targets:Array[Unit],pips:int)
