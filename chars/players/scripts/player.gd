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


var skill_consumed : Array = []
var actions_button = ["Action", "Rest", "Flee"]
var emotions = ""
var action_id = null
var stamina_cost = null
var power_value = null
var target_on = false

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

	GlobalEvent.start_process.connect(_on_start_pressed)
	GlobalEvent.skill_pressed.connect(_on_skill_pressed)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

		
func add_stamina_group(stamina: float):
	progress_bar.value += stamina

func add_stamina_player(stamina: float, id: int):
	if id == stats.id:
		progress_bar.value += stamina
		print("Curato: ", id, " +", stamina)
		
		
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
	var selected_skill_data = null
	
	for skill in stats.actions:
		if skill.id == id:
			selected_skill_data = skill
			
	if selected_skill_data == null:
		return
	
	var current_skill_info = {
		"id": selected_skill_data.id,
		"sta": selected_skill_data.stamina_consumed,
		"power": selected_skill_data.power,
		"emotion": selected_skill_data.emotion
	}
	
	skill_consumed.append(current_skill_info)
	emotions = current_skill_info["emotion"]
	if selected_skill_data.id == "kiss":
		set_target(true)
		
	GlobalEvent.update_button.emit()
	
	print("skill_info", skill_consumed)




func _on_start_pressed() -> void:

	if skill_consumed.size() > 0:
		for skill in skill_consumed:
			action_id = skill["id"]
			stamina_cost = skill["sta"]
			power_value = skill["power"]
	
	
			if action_id != "kiss" and action_id != "trust shield":
				if power_value != null:
					GlobalEvent.update_global_state.emit(power_value)
			elif action_id == "trust shield":
				if power_value != null:
					GlobalEvent.add_shield.emit(power_value)
			elif action_id == "kiss":
				if power_value != null:
					if GlobalEvent.target_cura != -1:
						GlobalEvent.add_stamina.emit(power_value, GlobalEvent.target_cura)
						GlobalEvent.target_cura = -1
				else:
					print("Target non valido")
	
			#if stamina_cost != null and stamina_cost > 0:
				#progress_bar.value -= stamina_cost
				#print("bar:", progress_bar.value)
		skill_consumed.clear()
	

func set_target(target: bool):
	target_on = target
