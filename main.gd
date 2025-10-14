extends Node2D
@onready var label_3: Label = $Label3
@onready var label_5: Label = $Label5
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var button_2: Button = $Button2
@onready var button_4: Button = $Button4
@onready var button_3: Button = $Button3
@onready var button_5: Button = $Button5
@onready var button_6: Button = $Button6
@onready var button_7: Button = $Button7
@export var start_num : int = 0
@export var combination_1 : String
@export var combination_2 : String
@export var players : Array[Player]
@export var enemies : Array[Enemy]
@onready var label_6: Label = $Label6
@onready var label_7: Label = $Label7


var shields = 0
var id_enemy = 0
var player_emotions = ""
var skills : Dictionary = {}
var target_name : int
var battle_end : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_3.text = str(start_num)
	label_5.text = str(shields)
	
	GlobalEvent.update_global_state.connect(add_points)
	GlobalEvent.add_shield.connect(add_shield)
	GlobalEvent.combination.connect(dance_group)
	GlobalEvent.update_button.connect(update_button)
	GlobalEvent.combination_2.connect(hug_group)
	GlobalEvent.remove_global_state.connect(remove_points)
	GlobalEvent.add_shield_enemy.connect(add_shield_enemy)
	player_turn()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if progress_bar.value <= progress_bar.min_value:
		print("GAME OVER")
	if progress_bar.value >= progress_bar.max_value:
		print("WINNER")
	label_3.text = str(start_num)
	label_5.text = str(shields)
	label_6.text = enemies[id_enemy].stats.name_char
	for player in players:
		if player.target_on:
			button_5.disabled = false
			button_6.disabled = false
			button_7.disabled = false
	
func player_turn():
	label_7.text = "turno player"
	id_enemy = 0
	for player in players:
		player.add_stamina_group(1)
	
func enemy_action_phase():
	label_7.text = "turno nemico"
	if enemies[id_enemy].stats.id == 0:
		enemies[id_enemy].stats.stamina += 1
		print("goblin_1: ", enemies[id_enemy].stats.stamina)
		await get_tree().create_timer(2).timeout
		if enemies[id_enemy].stats.stamina >= 3:
			GlobalEvent.remove_global_state.emit(enemies[id_enemy].stats.actions[1].power)
			enemies[id_enemy].stats.stamina -= enemies[id_enemy].stats.actions[1].stamina_consumed
			id_enemy += 1
		elif enemies[id_enemy].stats.stamina >= 1:
			GlobalEvent.remove_global_state.emit(enemies[id_enemy].stats.actions[0].power)
			enemies[id_enemy].stats.stamina -= enemies[id_enemy].stats.actions[0].stamina_consumed
			id_enemy += 1
		else:
			enemies[id_enemy].stats.stamina += 1
			id_enemy += 1
			
	if enemies[id_enemy].stats.id == 1:
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
	else:
		if shields > 0:
			shields -= points
		
func update_button():
	for player in players:
		if player_emotions.find(player.emotions) == -1:
			player_emotions += player.emotions
	print(player_emotions)
	if player_emotions == combination_1:
		button_4.disabled = false
	elif player_emotions == combination_2:
		button_3.disabled = false
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
	if comb == combination_1:
		progress_bar.value += 5
		start_num += 5
		button_3.disabled = true
		button_4.disabled = true
	
func hug_group(comb: String, stamina: float):
	for player in players:
		if comb == combination_2:
			player.add_stamina_group(stamina)
			button_3.disabled = true
			button_4.disabled = true
		


func _on_button_2_pressed() -> void:
	GlobalEvent.start_process.emit()
	start_off(true)
	button_3.disabled = true
	button_4.disabled = true
	player_emotions = ""
	for player in players:
		player.skill_consumed = []
		player.emotions = ""
	if not battle_end:
		await get_tree().create_timer(2).timeout
		enemy_action_phase()
		
func _on_button_4_pressed() -> void:
	GlobalEvent.combination.emit(player_emotions)
	player_emotions = ""
	start_off(true)
	skills.clear()
	for player in players:
		player.emotions = ""
		player.skill_consumed = []
	


func _on_button_3_pressed() -> void:
	GlobalEvent.combination_2.emit(player_emotions, 5)
	player_emotions = ""
	start_off(true)
	skills.clear()
	for player in players:
		player.emotions = ""
		player.skill_consumed = []


func _on_button_5_pressed() -> void:
	GlobalEvent.target_cura = 0
	for player in players:
		player.set_target(false)
		
#Difensore
func _on_button_6_pressed() -> void:
	GlobalEvent.target_cura = 1
	for player in players:
		player.set_target(false)


func _on_button_7_pressed() -> void:
	GlobalEvent.target_cura = 2
	for player in players:
		player.set_target(false)

func start_off(disabled: bool):
	button_2.disabled = disabled
