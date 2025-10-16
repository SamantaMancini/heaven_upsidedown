extends Node2D
class_name Player

@onready var sprite_2d: Sprite2D = $Sprite2D
@export var stats : Stat

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if stats == null:
		return
