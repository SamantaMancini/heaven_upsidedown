extends Node2D
class_name Enemy
@onready var enemy_sprite: Sprite2D = $EnemySprite
@export var sprite : Texture2D
@export var color_debug : Color
@export var stats : Stat

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemy_sprite.texture = sprite
	enemy_sprite.modulate = color_debug
	
