extends Node2D

signal update_global_state(power: float)
signal remove_global_state(power: float)
signal add_shield_enemy(shield: float)
signal add_shield(shield: float)
signal add_stamina(power: float)
signal combination(combination: String)
signal combination_2(combo: String, sta: float)
signal start_process
signal update_button

var target_cura = -1
var can_rest = true
