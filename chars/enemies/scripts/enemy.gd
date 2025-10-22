extends Node2D
class_name Enemy

@export var stats : Stat

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if stats == null:
		return
	
