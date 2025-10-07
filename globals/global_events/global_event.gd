extends Node2D

signal update_global_state(power: float)
signal remove_global_state(power: float)
signal add_shield(shield: float)

var actions : Dictionary = {}

func kiss_act(value: float, skill: Skill):
	return value + skill.power

func attack_act(value: float, skill: Skill):
	return value + skill.power

func defense_act(shields: int, skill: Skill):
	return shields + skill.power
	
func _ready() -> void:
	actions["kiss"] = kiss_act
	actions["happy song"] = attack_act
	actions["trust shield"] = defense_act
	print(actions)
