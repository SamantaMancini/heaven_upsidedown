extends Node2D
class_name Player

@export var stats : Stat
@onready var panel_3: Panel = $Sprite2D/CanvasLayer/Control/Panel3
@onready var panel_5: Panel = $Sprite2D/CanvasLayer/Control/Panel5
@onready var label: Label = $Sprite2D/CanvasLayer/Control/Panel/VBoxContainer/Label
@onready var progress_bar: ProgressBar = $Sprite2D/CanvasLayer/Control/Panel/VBoxContainer/HBoxContainer3/ProgressBar
@onready var label2 : Label = $Sprite2D/CanvasLayer/Label
@onready var label_4: Label = $Sprite2D/CanvasLayer/Control/Panel/VBoxContainer/HBoxContainer/Label4
@onready var label_6: Label = $Sprite2D/CanvasLayer/Control/Panel/VBoxContainer/HBoxContainer2/Label6
@onready var panel_2: Panel = $Sprite2D/CanvasLayer/Control/Panel2
@onready var v_actions: VBoxContainer = $Sprite2D/CanvasLayer/Control/Panel2/Actions
@onready var v_skills: VBoxContainer = $Sprite2D/CanvasLayer/Control/Panel3/VSkills
@onready var value_sta: Label = $Sprite2D/CanvasLayer/Control/Panel5/VBoxContainer/HBoxContainer/value_sta
@onready var value_power: Label = $Sprite2D/CanvasLayer/Control/Panel5/VBoxContainer/HBoxContainer/value_power
@onready var description: Label = $Sprite2D/CanvasLayer/Control/Panel5/VBoxContainer/description


var skill_consumed : Dictionary = {}
var actions_button = ["Action", "Rest", "Flee"]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	panel_3.hide()
	panel_5.hide()
	
	if stats == null:
		return

	label2.text = stats.name_char
	label.text = stats.role
	progress_bar.max_value = stats.stamina
	progress_bar.value = 2
	label_4.text = str(stats.will)
	label_6.text = str(stats.control)
	
	if actions_button.size() > 0:
		for button in range(0, len(actions_button)):
			var new_button = Button.new()
			new_button.text = actions_button[button]
			v_actions.add_child(new_button)
			new_button.connect("pressed", Callable(self, "_on_action_pressed").bind(actions_button[button], new_button))
			if actions_button[button] == "Flee":
				new_button.disabled = true
			
	if stats.actions.size() > 0:
		for button in range(0, len(stats.actions)):
			var skill_data = stats.actions[button]
			var action_id = skill_data.id
			var new_button = Button.new()
			new_button.text = action_id
			v_skills.add_child(new_button)
			new_button.connect("pressed", Callable(self, "_on_skill_pressed").bind(action_id, new_button))

	GlobalEvent.add_stamina.connect(add_stamina)
	GlobalEvent.start_process.connect(_on_start_pressed)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

	
func add_stamina(stamina: float):
	progress_bar.value += stamina
	
func _on_action_pressed(id: String, button: Button) -> void:
	if id == "Action":
		panel_2.hide()
		panel_3.show()
	if id == "Rest":
		if progress_bar.max_value < 10:
			progress_bar.max_value += 1
			
		progress_bar.value += 1
		if progress_bar.value >= 10:
			button.disabled = true
		else:
			button.disabled = false
			
func _on_skill_pressed(id: String, button: Button) -> void:
	panel_3.hide()
	panel_2.show()
	var selected_skill_data = null
	for skill in stats.actions:
		if skill.id == id:
			selected_skill_data = skill
			
	if selected_skill_data == null:
		return
	var current_sequence = skill_consumed.get("sequence", [])
	var current_skill_info = {
		"id": selected_skill_data.id,
		"sta": selected_skill_data.stamina_consumed,
		"power": selected_skill_data.power,
		"emotion": selected_skill_data.emotion
	}
	current_sequence.append(current_skill_info)
	skill_consumed["sequence"] = current_sequence
	
	var current_combination = skill_consumed.get("combination", "")
	
	if current_combination.is_empty():
		skill_consumed["combination"] = selected_skill_data.emotion
	else:
		skill_consumed["combination"] = current_combination + " , " + selected_skill_data.emotion
	
	print("Combinazione attuale:", skill_consumed["combination"])
	print("Dati della sequenza:", skill_consumed["sequence"])
	
func _on_button_4_pressed() -> void:
	if panel_3.is_visible_in_tree():
		panel_3.hide()
	
	panel_2.show()




#func _on_skill_1_mouse_entered() -> void:
	#if not panel_5.is_visible_in_tree():
		#panel_5.show()
	#if stats.stamina_consumed.size() > 0:
		#value_sta.text = str(stats.stamina_consumed[0])
	#if stats.power.size() > 0:
		#value_power.text = str(stats.power[0])
	#if stats.description.size() > 0:
		#description.text = stats.description[0]
#
#func _on_skill_1_mouse_exited() -> void:
	#if panel_5.is_visible_in_tree():
		#panel_5.hide()
#
#
#func _on_skill_2_mouse_entered() -> void:
	#if not panel_5.is_visible_in_tree():
		#panel_5.show()
	#if stats.stamina_consumed.size() > 0:
		#value_sta.text = str(stats.stamina_consumed[1])
	#if stats.power.size() > 0:
		#value_power.text = str(stats.power[1])
	#if stats.description.size() > 0:
		#description.text = stats.description[1]


#func _on_skill_2_mouse_exited() -> void:
	#if panel_5.is_visible_in_tree():
		#panel_5.hide()


func _on_start_pressed() -> void:
	if not skill_consumed.is_empty():
		var action_id = skill_consumed["id"]
		var power_value = skill_consumed["power"]
		var stamina_cost = skill_consumed["sta"]
		
		progress_bar.value -= stamina_cost
		if action_id != "kiss" and action_id != "trust shield":
			GlobalEvent.update_global_state.emit(power_value)
		if action_id == "trust shield":
			GlobalEvent.add_shield.emit(power_value)
			
		if action_id == "kiss":
			GlobalEvent.add_stamina.emit(power_value)
		skill_consumed.clear()
		
	


#func _on_rest_pressed() -> void:
	#if progress_bar.max_value < 10:
		#progress_bar.max_value += 1
	#progress_bar.value += 1
