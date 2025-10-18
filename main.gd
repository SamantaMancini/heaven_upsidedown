extends Node2D

@onready var progress_bar: ProgressBar = $CanvasLayer/Control/ProgressBar
@onready var h_box_container: HBoxContainer = $CanvasLayer/Control/ProgressBar/HBoxContainer
@onready var _0: Label = $"CanvasLayer/Control/ProgressBar/HBoxContainer/0"
@onready var _0s: Label = $"CanvasLayer/Control/ProgressBar/0s"
@onready var name_enemies: Label = $"CanvasLayer/Control/VBoxContainer/Name Enemies"
@onready var turn: Label = $CanvasLayer/Control/VBoxContainer/Turn
@onready var name_char: Label = $CanvasLayer/Control/Panel/HBoxContainer/VBoxContainer/Name
@onready var role: Label = $CanvasLayer/Control/Panel/HBoxContainer/VBoxContainer/Role
@onready var sta_min: Label = $CanvasLayer/Control/Panel/HBoxContainer/VBoxContainer/HBoxContainer/StaMin
@onready var will_v: Label = $CanvasLayer/Control/Panel/HBoxContainer/VBoxContainer/HBoxContainer2/WillV
@onready var control_v: Label = $CanvasLayer/Control/Panel/HBoxContainer/VBoxContainer/HBoxContainer3/ControlV
@onready var panel: Panel = $CanvasLayer/Control/Panel
@onready var action: Button = $CanvasLayer/Control/Panel/HBoxContainer/VBoxContainer2/Action
@onready var rest: Button = $CanvasLayer/Control/Panel/HBoxContainer/VBoxContainer2/Rest
@onready var v_box_container_3: VBoxContainer = $CanvasLayer/Control/Panel/HBoxContainer/VBoxContainer3
@onready var start: Button = $CanvasLayer/Control/Panel/HBoxContainer/VBoxContainer4/Start
@onready var hug: Button = $CanvasLayer/Control/Panel/HBoxContainer/VBoxContainer4/Hug
@onready var dance: Button = $CanvasLayer/Control/Panel/HBoxContainer/VBoxContainer4/Dance
@onready var player: Button = $CanvasLayer/Control/Player/Player
@onready var player_2: Button = $CanvasLayer/Control/Player2/Player2
@onready var player_3: Button = $CanvasLayer/Control/Player3/Player3

@export var start_num : int = 0
@export var combination_1 : String
@export var combination_2 : String
@export var players : Array[Player]
@export var enemies : Array[Enemy]
@export var buttons_cure : Array[Button]

var shields = 0
var id_enemy = 0
var id_player = 0
var player_emotions = ""
var skills = []
var target = false
var battle_end : bool = false
var player_counter : int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_0.text = str(start_num)
	_0s.text = str(shields)
	name_enemies.text = enemies[id_enemy].stats.name_char
	name_char.text = players[id_player].stats.name_char
	role.text = players[id_player].stats.role
	sta_min.text = str(players[id_player].stats.stamina)
	will_v.text = str(players[id_player].stats.will)
	control_v.text = str(players[id_player].stats.control)
	players[id_player].sprite_2d.modulate = Color.YELLOW
	GlobalEvent.update_global_state.connect(add_points)
	GlobalEvent.add_shield.connect(add_shield)
	GlobalEvent.combination.connect(dance_group)
	GlobalEvent.update_button.connect(update_button)
	GlobalEvent.combination_2.connect(hug_group)
	GlobalEvent.remove_global_state.connect(remove_points)
	GlobalEvent.add_shield_enemy.connect(add_shield_enemy)
	GlobalEvent.add_stamina.connect(stamina)
	GlobalEvent.start_process.connect(skill_consumed)
	player_turn()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target:
		for button in buttons_cure:
			button.show()
	if player_counter >= 3:
		start_off(false)
	if progress_bar.value <= progress_bar.min_value:
		battle_end = true
		panel.hide()
	if progress_bar.value >= progress_bar.max_value:
		battle_end = true
		panel.hide()
	name_char.text = players[id_player].stats.name_char
	role.text = players[id_player].stats.role
	sta_min.text = str(players[id_player].stats.stamina)
	will_v.text = str(players[id_player].stats.will)
	control_v.text = str(players[id_player].stats.control)
	_0.text = str(start_num)
	_0s.text = str(shields)

	if players[id_player].stats.stamina >= 10:
		rest.disabled = true
			
func selected_target(target_on: bool):
	target = target_on
	
func stamina(power: float, id: int):
	for player in players:
		if player.stats.id == id:
			player.stats.stamina += power
	

func skill_players():
	action.disabled = true
	rest.disabled = true
	for player in players:
		if id_player == player.stats.id:
			for skill in player.stats.actions:
				var button = Button.new()
				button.text = skill.id.capitalize()
				button.flat = true
				button.add_theme_font_size_override("font_size", 30)
				button.add_theme_constant_override("outline_size", 5)
				v_box_container_3.add_child(button)
				button.connect("pressed", Callable(self, "selected_skill").bind(skill.id, button, skill.power, skill.stamina_consumed, skill.emotion))
				if skill.stamina_consumed > player.stats.stamina:
					button.disabled = true
	var delete_button = Button.new()
	delete_button.text = "Cancel"
	delete_button.flat = true
	delete_button.add_theme_font_size_override("font_size", 30)
	delete_button.add_theme_constant_override("outline_size", 5)
	delete_button.connect("pressed",  Callable(self, "_on_delete_button_pressed"))
	v_box_container_3.add_child(delete_button)

func _on_delete_button_pressed():
	action.disabled = false
	rest.disabled = false
	for child in v_box_container_3.get_children():
		v_box_container_3.remove_child(child)
		child.queue_free()
		
func selected_skill(id: String, button: Button, power: float, stamina: float, emotion: String):
	var skill_info = {
		"id": id,
		"power": power
	}
	skills.append(skill_info)
	if player_emotions.is_empty():
		player_emotions = emotion
	else:
		if player_emotions.find(emotion) == -1:
			player_emotions += emotion
	if id != "kiss":
		players[id_player].stats.stamina -= stamina
		GlobalEvent.update_button.emit()
	else:
		selected_target(true)
		
	if id_player == 0:
		player.disabled = true
	elif id_player == 1:
		player_2.disabled = true
	else:
		player_3.disabled = true
	for child in v_box_container_3.get_children():
		v_box_container_3.remove_child(child)
		child.queue_free()
	
func player_turn():
	if battle_end:
		panel.hide()
		return
	
	player_counter = 0
	turn.text = "turno player"
	action.disabled = false
	rest.disabled = false
	start_off(true)
	panel.show()
	id_enemy = 0
	for player in players:
		if player.stats.stamina < 10:
			player.stats.stamina += 1
		
func enemy_action_phase():
	if progress_bar.value <= progress_bar.min_value:
		battle_end = true
		turn.text = "game over"
	if progress_bar.value >= progress_bar.max_value:
		battle_end = true
		turn.text = "win"
	
	panel.hide()
	if not battle_end:
		turn.text = "turno nemico"
		for enemy in enemies:
			name_enemies.text = enemy.stats.name_char
			enemy.stats.stamina += 1
			await get_tree().create_timer(1).timeout
			
			match enemy.stats.id:
				0:
					if enemy.stats.stamina >= 3:
						name_enemies.text = "Goblin Attack"
						GlobalEvent.remove_global_state.emit(enemy.stats.actions[1].power)
						enemy.stats.stamina -= enemy.stats.actions[1].stamina_consumed
					elif enemy.stats.stamina >= 1:
						GlobalEvent.remove_global_state.emit(enemy.stats.actions[0].power)
						name_enemies.text = "Goblin Attack"
						enemy.stats.stamina -= enemy.stats.actions[0].stamina_consumed
					else:
						name_enemies.text = "Goblin Rest"
						enemy.stats.stamina += 1
				1:
					if enemy.stats.stamina >= 2:
						GlobalEvent.add_shield_enemy.emit(enemy.stats.actions[1].power)
						name_enemies.text = "Blobby Defence"
						enemy.stats.stamina -= enemy.stats.actions[1].stamina_consumed
					elif enemy.stats.stamina >= 1:
						GlobalEvent.remove_global_state.emit(enemy.stats.actions[0].power)
						name_enemies.text = "Blobby Attack"
						enemy.stats.stamina -= enemy.stats.actions[0].stamina_consumed
						
					else:
						name_enemies.text = "Blobby Rest"
						enemy.stats.stamina += 1
				2:
					if enemy.stats.stamina >= 3:
						name_enemies.text = "Goblin Attack"
						GlobalEvent.remove_global_state.emit(enemy.stats.actions[1].power)
						enemy.stats.stamina -= enemy.stats.actions[1].stamina_consumed
					elif enemy.stats.stamina >= 1:
						name_enemies.text = "Goblin Attack"
						GlobalEvent.remove_global_state.emit(enemy.stats.actions[0].power)
						enemy.stats.stamina -= enemy.stats.actions[0].stamina_consumed
					else:
						name_enemies.text = "Goblin Rest"
						enemy.stats.stamina += 1
						
			await get_tree().create_timer(2).timeout
		player_turn()
	
	if progress_bar.value <= progress_bar.min_value:
		battle_end = true
		turn.text = "game over"
	if progress_bar.value >= progress_bar.max_value:
		battle_end = true
		turn.text = "win"
		
func remove_points(points: float):
	if shields <= 0:
		progress_bar.value -= points
		start_num -= points
	else:
		if shields > 0:
			shields -= points
		
func update_button():
	print(player_emotions)
	if player_emotions == combination_1:
		dance.disabled = false
	elif player_emotions == combination_2:
		hug.disabled = false
	player_counter += 1
	if player_counter >= 3:
		start_off(false)
	
func add_points(value: float):
	if shields >= 0:
		progress_bar.value += value
		start_num += value
	else:
		shields += value
#
func add_shield(shield: float):
	if shields < 0:
		shields = shield
	else:
		shields += shield

func add_shield_enemy(shield: float):
	if shields > 0:
		shields = -shield
	else:
		shields -= shield
	
func dance_group(comb: String):
	var damage = 5
	if comb == combination_1:
		if shields <= 0:
			shields = 0
		progress_bar.value += damage
		start_num += damage
	skills.clear()
	selected_target(false)
	player.disabled = false
	player_2.disabled = false
	player_3.disabled = false
	for button in buttons_cure:
		button.hide()

	enemy_action_phase()
	
func hug_group(comb: String, stamina: float):
	player.disabled = false
	player_2.disabled = false
	player_3.disabled = false
	for player in players:
		if comb == combination_2:
			if player.stats.stamina < 10:
				player.stats.stamina += stamina
			else:
				player.stats.stamina = 10
	skills.clear()
	selected_target(false)
	for button in buttons_cure:
		button.hide()
	enemy_action_phase()


func _on_start_pressed() -> void:
	GlobalEvent.start_process.emit()
	start_off(true)
	hug.disabled = true
	dance.disabled = true
	player_emotions = ""
	
		
func _on_dance_pressed() -> void:
	var skill_sta = null
	GlobalEvent.combination.emit(player_emotions)
	player_emotions = ""
	start_off(true)
	dance.disabled = true
	hug.disabled = true


func _on_hug_pressed() -> void:
	GlobalEvent.combination_2.emit(player_emotions, 5)
	player_emotions = ""
	start_off(true)
	dance.disabled = true
	hug.disabled = true


func start_off(disabled: bool):
	start.disabled = disabled


func _on_rest_pressed() -> void:
	players[id_player].stats.stamina += 1
	player_counter += 1
	rest.disabled = true
	action.disabled = true
	if id_player == 0:
		player.disabled = true
	elif id_player == 1:
		player_2.disabled = true
	else:
		player_3.disabled = true


func _on_action_pressed() -> void:
	skill_players()


func _on_player_pressed() -> void:
	id_player = 0
	players[0].sprite_2d.modulate = Color.YELLOW
	players[1].sprite_2d.modulate = Color.WHITE
	players[2].sprite_2d.modulate = Color.WHITE
	for child in v_box_container_3.get_children():
		v_box_container_3.remove_child(child)
		child.queue_free()
	action.disabled = false
	rest.disabled = false
	
func _on_player_2_pressed() -> void:
	id_player = 1
	players[0].sprite_2d.modulate = Color.WHITE
	players[1].sprite_2d.modulate = Color.YELLOW
	players[2].sprite_2d.modulate = Color.WHITE
	for child in v_box_container_3.get_children():
		v_box_container_3.remove_child(child)
		child.queue_free()
	action.disabled = false
	rest.disabled = false
	
func _on_player_3_pressed() -> void:
	id_player = 2
	players[0].sprite_2d.modulate = Color.WHITE
	players[1].sprite_2d.modulate = Color.WHITE
	players[2].sprite_2d.modulate = Color.YELLOW
	for child in v_box_container_3.get_children():
		v_box_container_3.remove_child(child)
		child.queue_free()
	action.disabled = false
	rest.disabled = false


func _on_cure_pressed() -> void:
	GlobalEvent.target_cura = 0
	player_counter += 1
	players[2].stats.stamina -= players[2].stats.actions[0].stamina_consumed
	for button in buttons_cure:
		button.hide()
	selected_target(false)
	GlobalEvent.update_button.emit()
	rest.disabled = true
	action.disabled = true
	
func _on_cure_2_pressed() -> void:
	GlobalEvent.target_cura = 1
	player_counter += 1
	players[2].stats.stamina -= players[2].stats.actions[0].stamina_consumed
	for button in buttons_cure:
		button.hide()
	selected_target(false)
	GlobalEvent.update_button.emit()
	rest.disabled = true
	action.disabled = true
	
func _on_cure_3_pressed() -> void:
	GlobalEvent.target_cura = 2
	player_counter += 1
	players[2].stats.stamina -= players[2].stats.actions[0].stamina_consumed
	for button in buttons_cure:
		button.hide()
	selected_target(false)
	GlobalEvent.update_button.emit()
	rest.disabled = true
	action.disabled = true

func skill_consumed():
	var action_id = null
	var power_value = null
	player.disabled = false
	player_2.disabled = false
	player_3.disabled = false
	for skill in skills:
		action_id = skill["id"]
		power_value = skill["power"]
	
		if action_id == "kiss":
			if GlobalEvent.target_cura != -1:
				GlobalEvent.add_stamina.emit(power_value, GlobalEvent.target_cura)
				GlobalEvent.target_cura = -1
		elif action_id == "trust shield":
			GlobalEvent.add_shield.emit(power_value)
		else:
			GlobalEvent.update_global_state.emit(power_value)
		
			
	skills.clear()
	enemy_action_phase()
