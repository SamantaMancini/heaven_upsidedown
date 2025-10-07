extends Node2D

signal update_global_state(power: float)
signal remove_global_state(power: float)
signal add_shield(shield: float)

var actions : Dictionary = {}

func kiss_act(stamina: float, value: float):
	return value + stamina
	
func _ready() -> void:
	actions["kiss"] = kiss_act
	print(actions)
