extends Node2D

@export var stats : Stat
@onready var panel_3: Panel = $Sprite2D/CanvasLayer/Control/Panel3
@onready var panel_5: Panel = $Sprite2D/CanvasLayer/Control/Panel5
@onready var panel_4: Panel = $Sprite2D/CanvasLayer/Control/Panel4
@onready var label: Label = $Sprite2D/CanvasLayer/Control/Panel/VBoxContainer/Label
@onready var progress_bar: ProgressBar = $Sprite2D/CanvasLayer/Control/Panel/VBoxContainer/HBoxContainer3/ProgressBar
@onready var label2 : Label = $Sprite2D/CanvasLayer/Label
@onready var label_4: Label = $Sprite2D/CanvasLayer/Control/Panel/VBoxContainer/HBoxContainer/Label4
@onready var label_6: Label = $Sprite2D/CanvasLayer/Control/Panel/VBoxContainer/HBoxContainer2/Label6
@onready var panel_2: Panel = $Sprite2D/CanvasLayer/Control/Panel2
@onready var button: Button = $Sprite2D/CanvasLayer/Control/Panel3/VBoxContainer/skill1
@onready var button_2: Button = $Sprite2D/CanvasLayer/Control/Panel3/VBoxContainer/skill2
@onready var value_sta: Label = $Sprite2D/CanvasLayer/Control/Panel5/VBoxContainer/HBoxContainer/value_sta
@onready var value_power: Label = $Sprite2D/CanvasLayer/Control/Panel5/VBoxContainer/HBoxContainer/value_power
@onready var description: Label = $Sprite2D/CanvasLayer/Control/Panel5/VBoxContainer/description
@onready var rest: Button = $Sprite2D/CanvasLayer/Control/Panel2/VBoxContainer/Rest

var skill_consumed : Dictionary = {}



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	panel_3.hide()
	panel_4.hide()
	panel_5.hide()
	
	if stats == null:
		return
	
	label2.text = stats.name_char
	label.text = stats.role
	progress_bar.max_value = stats.stamina
	progress_bar.value = 2
	label_4.text = str(stats.will)
	label_6.text = str(stats.control)
	
	if stats.actions.size() > 0:
		button.text = stats.actions[0]
		button_2.text = stats.actions[1]
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if progress_bar.value <= 0:
		button.disabled = true
	else:
		button.disabled = false
		
	if progress_bar.value < stats.stamina_consumed[1]:
		button_2.disabled = true
	else:
		button_2.disabled = false
		
	if progress_bar.value >= 10:
		rest.disabled = true
	else:
		rest.disabled = false

func _on_button_pressed() -> void:
	if panel_2.is_visible_in_tree():
		panel_2.hide()
	
	panel_3.show()
	


func _on_button_4_pressed() -> void:
	if panel_3.is_visible_in_tree():
		panel_3.hide()
	
	panel_2.show()


func _on_skill_1_pressed() -> void:
	if not panel_4.is_visible_in_tree():
		panel_4.show()
	panel_3.hide()
	skill_consumed["skill"] = stats.actions[0]
	skill_consumed["sta"] = stats.stamina_consumed[0]
	skill_consumed["power"] = stats.power[0]
	skill_consumed["type"] = stats.type[0]
	print("skill_ready :", skill_consumed)

func _on_skill_2_pressed() -> void:
	if not panel_4.is_visible_in_tree():
		panel_4.show()
	panel_3.hide()
	skill_consumed["skill"] = stats.actions[1]
	skill_consumed["sta"] = stats.stamina_consumed[1]
	skill_consumed["power"] = stats.power[1]
	skill_consumed["type"] = stats.type[1]
	
	print("skill_ready :", skill_consumed)

func _on_cancel_pressed() -> void:
	if panel_4.is_visible_in_tree():
		panel_4.hide()
	panel_3.show()
	skill_consumed.clear()
	print("dict_empty :", skill_consumed)

func _on_skill_1_mouse_entered() -> void:
	if not panel_5.is_visible_in_tree():
		panel_5.show()
	if stats.stamina_consumed.size() > 0:
		value_sta.text = str(stats.stamina_consumed[0])
	if stats.power.size() > 0:
		value_power.text = str(stats.power[0])
	if stats.description.size() > 0:
		description.text = stats.description[0]

func _on_skill_1_mouse_exited() -> void:
	if panel_5.is_visible_in_tree():
		panel_5.hide()


func _on_skill_2_mouse_entered() -> void:
	if not panel_5.is_visible_in_tree():
		panel_5.show()
	if stats.stamina_consumed.size() > 0:
		value_sta.text = str(stats.stamina_consumed[1])
	if stats.power.size() > 0:
		value_power.text = str(stats.power[1])
	if stats.description.size() > 0:
		description.text = stats.description[1]


func _on_skill_2_mouse_exited() -> void:
	if panel_5.is_visible_in_tree():
		panel_5.hide()


func _on_start_pressed() -> void:
	if not skill_consumed.is_empty():
		progress_bar.value -= skill_consumed["sta"]
		var power_value = skill_consumed["power"]
		if skill_consumed["type"] == "attack":
			GlobalEvent.update_global_state.emit(power_value)
		if skill_consumed["type"] == "defence":
			GlobalEvent.add_shield.emit(power_value)
		skill_consumed.clear()
		
	panel_4.hide()
	panel_2.show()


func _on_rest_pressed() -> void:
	if progress_bar.max_value < 10:
		progress_bar.max_value += 1
	progress_bar.value += 1
