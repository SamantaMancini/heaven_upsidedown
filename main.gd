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
var skills : Dictionary = {}
var target_name : int
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
	
	GlobalEvent.update_global_state.connect(add_points)
	GlobalEvent.add_shield.connect(add_shield)
	GlobalEvent.combination.connect(dance_group)
	GlobalEvent.update_button.connect(update_button)
	GlobalEvent.combination_2.connect(hug_group)
	GlobalEvent.remove_global_state.connect(remove_points)
	GlobalEvent.add_shield_enemy.connect(add_shield_enemy)
	GlobalEvent.add_stamina.connect(stamina)
	player_turn()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if progress_bar.value <= progress_bar.min_value:
		battle_end = true
	if progress_bar.value >= progress_bar.max_value:
		battle_end = true
	name_enemies.text = enemies[id_enemy].stats.name_char
	name_char.text = players[id_player].stats.name_char
	role.text = players[id_player].stats.role
	sta_min.text = str(players[id_player].stats.stamina)
	will_v.text = str(players[id_player].stats.will)
	control_v.text = str(players[id_player].stats.control)
	_0.text = str(start_num)
	for player in players:
		if player.target_on:
			for button in buttons_cure:
				button.show()

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
				button.connect("pressed", Callable(self, "selected_skill").bind(skill.id, button))
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
		
func selected_skill(id: String, button: Button):
	GlobalEvent.skill_pressed.emit(id, button)
	for child in v_box_container_3.get_children():
		v_box_container_3.remove_child(child)
		child.queue_free()
	action.disabled = false
	rest.disabled = false
	
func player_turn():
	player_counter = 0
	turn.text = "turno player"
	action.disabled = false
	panel.show()
	id_enemy = 0
	for player in players:
		player.stats.stamina += 1
		
func enemy_action_phase():
	turn.text = "turno nemico"
	panel.hide()
	if enemies[id_enemy].stats.id == 0:
		name_enemies.text = enemies[id_enemy].stats.name_char
		enemies[id_enemy].stats.stamina += 1
		await get_tree().create_timer(2).timeout
		if enemies[id_enemy].stats.stamina >= 3:
			GlobalEvent.remove_global_state.emit(enemies[id_enemy].stats.actions[1].power)
			enemies[id_enemy].stats.stamina -= enemies[id_enemy].stats.actions[1].stamina_consumed
			id_enemy += 1
		elif enemies[id_enemy].stats.stamina >= 1:
			name_enemies.text = enemies[id_enemy].stats.name_char
			GlobalEvent.remove_global_state.emit(enemies[id_enemy].stats.actions[0].power)
			enemies[id_enemy].stats.stamina -= enemies[id_enemy].stats.actions[0].stamina_consumed
			id_enemy += 1
		else:
			enemies[id_enemy].stats.stamina += 1
			id_enemy += 1
			
	if enemies[id_enemy].stats.id == 1:
		name_enemies.text = enemies[id_enemy].stats.name_char
		enemies[id_enemy].stats.stamina += 1
		await get_tree().create_timer(2).timeout
		if enemies[id_enemy].stats.stamina >= 2:
			GlobalEvent.add_shield_enemy.emit(enemies[id_enemy].stats.actions[1].power)
			enemies[id_enemy].stats.stamina -= enemies[id_enemy].stats.actions[1].stamina_consumed
			id_enemy += 1
		elif enemies[id_enemy].stats.stamina >= 1:
			GlobalEvent.remove_global_state.emit(enemies[id_enemy].stats.actions[0].power)
			enemies[id_enemy].stats.stamina -= enemies[id_enemy].stats.actions[0].stamina_consumed
			id_enemy += 1
		else:
			enemies[id_enemy].stats.stamina += 1
			id_enemy += 1
			
	if enemies[id_enemy].stats.id == 2:
		enemies[id_enemy].stats.stamina += 1
		await get_tree().create_timer(2).timeout
		if enemies[id_enemy].stats.stamina >= 3:
			GlobalEvent.remove_global_state.emit(enemies[id_enemy].stats.actions[1].power)
			enemies[id_enemy].stats.stamina -= enemies[id_enemy].stats.actions[1].stamina_consumed
			player_turn()
		elif enemies[id_enemy].stats.stamina >= 1:
			GlobalEvent.remove_global_state.emit(enemies[id_enemy].stats.actions[0].power)
			enemies[id_enemy].stats.stamina -= enemies[id_enemy].stats.actions[0].stamina_consumed
			player_turn()
		else:
			enemies[id_enemy].stats.stamina += 1
			player_turn()
			
func remove_points(points: float):
	if shields <= 0:
		progress_bar.value -= points
		start_num -= points
		_0s.hide()
		h_box_container.show()
	else:
		if shields > 0:
			shields -= points
		
func update_button():
	for player in players:
		if player_emotions.find(player.emotions) == -1:
			player_emotions += player.emotions

	if player_emotions == combination_1:
		dance.disabled = false
	elif player_emotions == combination_2:
		hug.disabled = false
	player_counter += 1
	
	if player_counter == 3:
		start_off(false)
		
func add_points(value: float):
	if shields >= 0:
		progress_bar.value += value
		start_num += value
		_0s.hide()
		h_box_container.show()
	else:
		shields += value
#
func add_shield(shield: float):
	if shields < 0:
		shields = shield
		_0s.show()
		h_box_container.hide()
	else:
		shields += shield

func add_shield_enemy(shield: float):
	if shields > 0:
		shields = -shield
		_0s.show()
		h_box_container.hide()
	else:
		shields -= shield
	
func dance_group(comb: String):
	if comb == combination_1:
		if shields >= 0:
			_0s.hide()
			h_box_container.show()
			progress_bar.value += 5
			start_num += 5
		else:
			shields += 5
	enemy_action_phase()
	
func hug_group(comb: String, stamina: float):
	for player in players:
		if comb == combination_2:
			player.stats.stamina += stamina
	enemy_action_phase()
		


func _on_start_pressed() -> void:
	GlobalEvent.start_process.emit()
	start_off(true)
	hug.disabled = true
	dance.disabled = true
	player_emotions = ""
	for player in players:
		player.skill_consumed = []
		player.emotions = ""
	if not battle_end:
		await get_tree().create_timer(2).timeout
		enemy_action_phase()
		
func _on_dance_pressed() -> void:
	GlobalEvent.combination.emit(player_emotions)
	player_emotions = ""
	start_off(true)
	skills.clear()
	dance.disabled = true
	hug.disabled = true
	for player in players:
		player.emotions = ""
		player.skill_consumed = []
	


func _on_hug_pressed() -> void:
	GlobalEvent.combination_2.emit(player_emotions, 5)
	player_emotions = ""
	start_off(true)
	skills.clear()
	hug.disabled = true
	for player in players:
		player.emotions = ""
		player.skill_consumed = []


func start_off(disabled: bool):
	start.disabled = disabled


func _on_rest_pressed() -> void:
	players[id_player].stats.stamina += 1
	
			

func _on_action_pressed() -> void:
	skill_players()


func _on_player_pressed() -> void:
	id_player = 0
	for child in v_box_container_3.get_children():
		v_box_container_3.remove_child(child)
		child.queue_free()
	action.disabled = false
	rest.disabled = false
	
func _on_player_2_pressed() -> void:
	id_player = 1
	for child in v_box_container_3.get_children():
		v_box_container_3.remove_child(child)
		child.queue_free()
	action.disabled = false
	rest.disabled = false
	
func _on_player_3_pressed() -> void:
	id_player = 2
	for child in v_box_container_3.get_children():
		v_box_container_3.remove_child(child)
		child.queue_free()
	action.disabled = false
	rest.disabled = false


func _on_cure_pressed() -> void:
	GlobalEvent.target_cura = 0

func _on_cure_2_pressed() -> void:
	GlobalEvent.target_cura = 1
	
func _on_cure_3_pressed() -> void:
	GlobalEvent.target_cura = 2
