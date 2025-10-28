extends Node2D
@onready var v_box_container: VBoxContainer = $CanvasLayer/Control/VBoxContainer
@onready var progress_bar: ProgressBar = $CanvasLayer/Control/ProgressBar
@onready var h_box_container: HBoxContainer = $CanvasLayer/Control/ProgressBar/HBoxContainer
@onready var _0: Label = $"CanvasLayer/Control/ProgressBar/HBoxContainer/0"
@onready var _0s: ProgressBar = $"CanvasLayer/Control/ProgressBar/0s"
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
@onready var action_label: Label = $CanvasLayer/Control/Player/Action_Label
@onready var action_label_2: Label = $CanvasLayer/Control/Player2/Action_Label2
@onready var action_label_3: Label = $CanvasLayer/Control/Player3/Action_Label3
@onready var panel_2: Panel = $CanvasLayer/Control/Panel2
@onready var title: Label = $CanvasLayer/Control/Panel2/Vbox/Title
@onready var image: TextureRect = $CanvasLayer/Control/Panel/Image
@onready var v_box_container_5: VBoxContainer = $CanvasLayer/Control/Panel/HBoxContainer/VBoxContainer5
@onready var v_box_container_4: VBoxContainer = $CanvasLayer/Control/Panel/HBoxContainer/VBoxContainer4


@export var start_num : int = 0
@export var combination_1 : String
@export var combination_2 : String
@export var players : Array[Player]
@export var enemies : Array[Enemy]
@export var buttons_cure : Array[Button]
@export var button_players : Array[Button]

var shields : float = 0
var id_enemy = 0
var id_player = 0
var player_emotions = ""
var skills = []
var target = false
var battle_end : bool = false
var player_counter : int = 0
var action_selected = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_0.text = str(start_num)
	_0s.value = shields
	name_enemies.text = enemies[id_enemy].stats.name_char
	stats_player()
	change_color_player(0, Color.YELLOW)
	GlobalEvent.update_global_state.connect(add_points)
	GlobalEvent.add_shield.connect(add_shield)
	GlobalEvent.combination.connect(dance_group)
	GlobalEvent.update_button.connect(update_button)
	GlobalEvent.combination_2.connect(hug_group)
	GlobalEvent.remove_global_state.connect(remove_points)
	GlobalEvent.add_shield_enemy.connect(add_shield_enemy)
	GlobalEvent.add_stamina.connect(stamina)
	GlobalEvent.start_process.connect(skill_consumed)
	GlobalEvent.end_tutorial.connect(start_game)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Escape"):
		get_tree().quit()
		
	if players[id_player].stats.stamina >= 10:
		buttons_cure[id_player].disabled = true
		rest.disabled = true
	else:
		buttons_cure[id_player].disabled = false
		
	draw_buttons_cure()
				
	if player_counter >= 3:
		start_off(false)
		
	battle_end_conditions()
	stats_player()
	_0.text = str(start_num)
	_0s.value = shields

func start_game():
	player_turn()
	v_box_container.show()
	
func stats_player():
	image.texture = players[id_player].stats.image
	image.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	name_char.text = players[id_player].stats.name_char
	role.text = players[id_player].stats.role
	sta_min.text = str(players[id_player].stats.stamina)
	will_v.text = str(players[id_player].stats.will)
	control_v.text = str(players[id_player].stats.control)
	
func draw_buttons_cure():
	for button in buttons_cure:
		if target:
			button.show()
		else:
			button.hide()
			
func battle_end_conditions():
	if progress_bar.value <= progress_bar.min_value:
		battle_end = true
		turn.hide()
		name_enemies.hide()
		panel.hide()
		panel_2.show()
		title.text = "Game Over"
		GlobalSounds.get_node("Music").stop()
		
	if progress_bar.value >= progress_bar.max_value:
		battle_end = true
		turn.hide()
		name_enemies.hide()
		panel.hide()
		panel_2.show()
		title.text = "Win"
		GlobalSounds.get_node("Music").stop()
		
func selected_target(target_on: bool):
	target = target_on
	
func stamina(power: float, id: int):
	for player in players:
		if player.stats.id == id:
			player.stats.stamina += power
	
func action_button_disabled(disabled: bool):
	action.disabled = disabled
	rest.disabled = disabled
	
func skill_players():
	action_button_disabled(true)
	var font_add = preload("res://fonts/nes.ttf")
	for player in players:
		if id_player == player.stats.id:
			for skill in player.stats.actions:
				var button = Button.new()
				button.text = skill.id.capitalize()
				button.flat = true
				button.add_theme_font_size_override("font_size", 35)
				button.add_theme_constant_override("outline_size", 5)
				button.add_theme_font_override("font", font_add)
				v_box_container_3.add_child(button)
				button.connect("pressed", Callable(self, "selected_skill").bind(skill.id, button, skill.power, skill.stamina_consumed, skill.emotion))
				button.connect("mouse_entered", Callable(self, "show_skill").bind(skill.id, skill.description, skill.power, skill.stamina_consumed, button))
				button.connect("mouse_exited", Callable(self, "remove_skill").bind(v_box_container_4))
				if skill.stamina_consumed > player.stats.stamina:
					button.disabled = true
				if shields >= 10:
					if skill.id == "Fides":
						button.disabled = true
	var delete_button = Button.new()
	delete_button.text = "Cancel"
	delete_button.flat = true
	delete_button.add_theme_font_size_override("font_size", 35)
	delete_button.add_theme_constant_override("outline_size", 5)
	delete_button.add_theme_font_override("font", font_add)
	delete_button.connect("pressed",  Callable(self, "_on_delete_button_pressed"))
	v_box_container_3.add_child(delete_button)

func remove_children():
	for child in v_box_container_3.get_children():
		v_box_container_3.remove_child(child)
		child.queue_free()
		
func _on_delete_button_pressed():
	action_button_disabled(false)
	remove_children()
	GlobalSounds.get_node("SFX").play()

func show_skill(id: String, desc: String, power: float, stamina: float, button: Button):
	if not button.disabled:
		var new_title = Label.new()
		var font_add = preload("res://fonts/nes.ttf")
		new_title.text = id
		new_title.add_theme_font_size_override("font_size", 30)
		new_title.add_theme_constant_override("outline_size", 5)
		new_title.add_theme_font_override("font", font_add)
		
		var new_desc = Label.new()
		new_desc.text = desc
		new_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		new_desc.add_theme_font_size_override("font_size", 25)
		new_desc.add_theme_constant_override("outline_size", 5)
		new_desc.add_theme_font_override("font", font_add)
		
		var new_h_box = HBoxContainer.new()
		var new_power = Label.new()
		new_power.text = "Power"
		new_power.add_theme_font_size_override("font_size", 25)
		new_power.add_theme_constant_override("outline_size", 5)
		new_power.add_theme_font_override("font", font_add)
		
		var new_power_desc = Label.new()
		new_power_desc.text = "+" + str(power)
		new_power_desc.add_theme_font_size_override("font_size", 25)
		new_power_desc.add_theme_constant_override("outline_size", 5)
		new_power_desc.add_theme_font_override("font", font_add)
		
		var new_stamina = Label.new()
		new_stamina.text = "Stamina"
		new_stamina.add_theme_font_size_override("font_size", 25)
		new_stamina.add_theme_constant_override("outline_size", 5)
		new_stamina.add_theme_font_override("font", font_add)
		
		var new_stamina_desc = Label.new()
		new_stamina_desc.text = "-" + str(stamina)
		new_stamina_desc.add_theme_font_size_override("font_size", 25)
		new_stamina_desc.add_theme_constant_override("outline_size", 5)
		new_stamina_desc.add_theme_font_override("font", font_add)
		
		new_h_box.add_child(new_power)
		new_h_box.add_child(new_power_desc)
		new_h_box.add_child(new_stamina)
		new_h_box.add_child(new_stamina_desc)
		v_box_container_5.add_child(new_title)
		v_box_container_5.add_child(new_desc)
		v_box_container_5.add_child(new_h_box)
		v_box_container_4.hide()
	
func remove_skill(v_box: VBoxContainer):
	for child in v_box_container_5.get_children():
		v_box_container_5.remove_child(child)
		child.queue_free()
	v_box.show()
	
		
func selected_skill(id: String, button: Button, power: float, stamina: float, emotion: String):
	GlobalSounds.get_node("SFX").play()
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
		if id_player == 0:
			action_label.show()
			action_label.text = id
		else:
			action_label_2.show()
			action_label_2.text = id
	else:
		selected_target(true)
		
	if not action_selected.has(id_player):
		action_selected.append(id_player)
	action_button_disabled(true)
	remove_children()
		
		
func player_turn():
	if battle_end:
		panel.hide()
		return
	for player in players:
		if player.stats.stamina < 10:
			player.stats.stamina += 1
		else:
			player.stats.stamina = 10
	player_counter = 0
	turn.text = "Player Turn"
	action_button_disabled(false)
	start_off(true)
	panel.show()
	id_enemy = 0

		
func enemy_action_phase():
	battle_end_conditions()
	panel.hide()
	if not battle_end:
		turn.text = "Enemy Turn"
		for enemy in enemies:
			name_enemies.text = enemy.stats.name_char
			if enemy.stats.stamina < 10:
				enemy.stats.stamina += 1
			else:
				enemy.stats.stamina = 10
			await get_tree().create_timer(1).timeout
			
			match enemy.stats.id:
				0:
					goblin_attack(enemy)
				1:
					blobby_attack(enemy)
				2:
					goblin_attack(enemy)
						
			await get_tree().create_timer(2).timeout
		
		player_turn()
	battle_end_conditions()
	
func goblin_attack(enemy):
	if enemy.stats.stamina >= 3:
		GlobalEvent.remove_global_state.emit(enemy.stats.actions[1].power)
		enemy.stats.stamina -= enemy.stats.actions[1].stamina_consumed
		name_enemies.text = enemy.stats.actions[1].id
	elif enemy.stats.stamina >= 1:
		GlobalEvent.remove_global_state.emit(enemy.stats.actions[0].power)
		enemy.stats.stamina -= enemy.stats.actions[0].stamina_consumed
		name_enemies.text = enemy.stats.actions[0].id
	else:
		name_enemies.text = "Goblin Rest"
		enemy.stats.stamina += 3
		
func blobby_attack(enemy):
	if enemy.stats.stamina >= 2 and shields <= 10:
		GlobalEvent.add_shield_enemy.emit(enemy.stats.actions[1].power)
		name_enemies.text = enemy.stats.actions[1].id
		enemy.stats.stamina -= enemy.stats.actions[1].stamina_consumed
	elif enemy.stats.stamina >= 1:
		GlobalEvent.remove_global_state.emit(enemy.stats.actions[0].power)
		name_enemies.text = enemy.stats.actions[0].id
		enemy.stats.stamina -= enemy.stats.actions[0].stamina_consumed
	else:
		name_enemies.text = "Blobby Rest"
		enemy.stats.stamina += 3
		
func remove_points(damage: float):
	if shields > 0 and _0s.modulate == Color.WHITE:
		if damage > shields:
			var damage_overflow = damage - shields
			shields = 0
			progress_bar.value -= damage_overflow
			start_num -= damage_overflow
		else:
			shields -= damage
	else:
		progress_bar.value -= damage
		start_num -= damage
			
func combination_disabled(disabled_dance: bool, disabled_hug):
	dance.disabled = disabled_dance
	hug.disabled = disabled_hug
	
func update_button():
	if player_emotions == combination_1:
		combination_disabled(false, true)
	elif player_emotions == combination_2:
		combination_disabled(true, false)
	player_counter += 1
	
	
func add_points(damage: float):
	if shields > 0 and _0s.modulate == Color.DARK_GREEN:
		if damage > shields:
			var damage_overflow = damage - shields
			shields = 0
			progress_bar.value += damage_overflow
			start_num += damage_overflow
		else:
			shields -= damage
	else:
		progress_bar.value += damage
		start_num += damage
			

func add_shield(shield: float):
		if _0s.modulate != Color.WHITE:
			shields = shield
			_0s.modulate = Color.WHITE
		else:
			shields += shield

func add_shield_enemy(shield: float):
	if shields >= 0 and _0s.modulate == Color.WHITE:
		shields = shield
		_0s.modulate = Color.DARK_GREEN
	else:
		shields += shield

func dance_group(comb: String):
	GlobalSounds.get_node("SFX").play()
	var damage = 5
	if comb == combination_1:
		GlobalEvent.update_global_state.emit(damage)
	
	selected_target(false)
	skills.clear()
	action_selected.clear()
	enemy_action_phase()
	
func hug_group(comb: String, stamina: float):
	GlobalSounds.get_node("SFX").play()
	for player in players:
		if comb == combination_2:
			if player.stats.stamina < 10:
				player.stats.stamina += 1
	
	skills.clear()
	action_selected.clear()
	selected_target(false)
	enemy_action_phase()


func _on_start_pressed() -> void:
	GlobalEvent.start_process.emit()
	GlobalSounds.get_node("SFX").play()
	start_off(true)
	combination_disabled(true, true)
	player_emotions = ""
	action_label.hide()
	action_label_2.hide()
	action_label_3.hide()
		
func _on_dance_pressed() -> void:
	GlobalSounds.get_node("SFX").play()
	var skill_sta = null
	GlobalEvent.combination.emit(player_emotions)
	player_emotions = ""
	start_off(true)
	combination_disabled(true, true)
	action_label.hide()
	action_label_2.hide()
	action_label_3.hide()
	
func _on_dance_mouse_entered() -> void:
	if not dance.disabled:
		var new_title = Label.new()
		var font_add = preload("res://fonts/nes.ttf")
		new_title.text = "Dance Group"
		new_title.add_theme_font_size_override("font_size", 30)
		new_title.add_theme_constant_override("outline_size", 5)
		new_title.add_theme_font_override("font", font_add)
		
		var new_desc = Label.new()
		new_desc.text = "A dance group that boots global meter."
		new_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		new_desc.add_theme_font_size_override("font_size", 25)
		new_desc.add_theme_constant_override("outline_size", 5)
		new_desc.add_theme_font_override("font", font_add)
		
		var new_h_box = HBoxContainer.new()
		var new_emotion = Label.new()
		new_emotion.text = "Emotion: Happy+Trust+Love"
		new_emotion.add_theme_font_size_override("font_size", 25)
		new_emotion.add_theme_constant_override("outline_size", 5)
		new_emotion.add_theme_font_override("font", font_add)
		
		var new_stamina = Label.new()
		new_stamina.text = "Power: +5"
		new_stamina.add_theme_font_size_override("font_size", 25)
		new_stamina.add_theme_constant_override("outline_size", 5)
		new_stamina.add_theme_font_override("font", font_add)
		
		new_h_box.add_child(new_emotion)
		new_h_box.add_child(new_stamina)
		v_box_container_5.add_child(new_title)
		v_box_container_5.add_child(new_desc)
		v_box_container_5.add_child(new_h_box)
		
func _on_dance_mouse_exited() -> void:
	remove_skill(v_box_container_3)
	
func _on_hug_pressed() -> void:
	GlobalEvent.combination_2.emit(player_emotions, 5)
	player_emotions = ""
	start_off(true)
	combination_disabled(true, true)
	action_label.hide()
	action_label_2.hide()
	action_label_3.hide()

func _on_hug_mouse_entered() -> void:
	if not hug.disabled:
		var new_title = Label.new()
		var font_add = preload("res://fonts/nes.ttf")
		new_title.text = "Hug Group"
		new_title.add_theme_font_size_override("font_size", 30)
		new_title.add_theme_constant_override("outline_size", 5)
		new_title.add_theme_font_override("font", font_add)
		
		var new_desc = Label.new()
		new_desc.text = "Add 1 point stamina to your group"
		new_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		new_desc.add_theme_font_size_override("font_size", 25)
		new_desc.add_theme_constant_override("outline_size", 5)
		new_desc.add_theme_font_override("font", font_add)
		
		var new_h_box = HBoxContainer.new()
		var new_emotion = Label.new()
		new_emotion.text = "Emotion: Trust+Love"
		new_emotion.add_theme_font_size_override("font_size", 25)
		new_emotion.add_theme_constant_override("outline_size", 5)
		new_emotion.add_theme_font_override("font", font_add)
		
		var new_stamina = Label.new()
		new_stamina.text = "Stamina: +1"
		new_stamina.add_theme_font_size_override("font_size", 25)
		new_stamina.add_theme_constant_override("outline_size", 5)
		new_stamina.add_theme_font_override("font", font_add)
		
		new_h_box.add_child(new_emotion)
		new_h_box.add_child(new_stamina)
		v_box_container_5.add_child(new_title)
		v_box_container_5.add_child(new_desc)
		v_box_container_5.add_child(new_h_box)

func _on_hug_mouse_exited() -> void:
	remove_skill(v_box_container_3)

func start_off(disabled: bool):
	start.disabled = disabled


func _on_rest_pressed() -> void:
	players[id_player].stats.stamina += 1
	player_counter += 1
	GlobalSounds.get_node("SFX").play()
	if not action_selected.has(id_player):
		action_selected.append(id_player)
	action_button_disabled(true)
	match id_player:
		0:
			action_label.text = "Rest"
			action_label.show()
		1:
			action_label_2.text = "Rest"
			action_label_2.show()
		2:
			action_label_3.text = "Rest"
			action_label_3.show()

func action_selected_player(id: int):
	if action_selected.has(id):
		action_button_disabled(true)
	else:
		action_button_disabled(false)
		
func _on_action_pressed() -> void:
	skill_players()
	GlobalSounds.get_node("SFX").play()

func change_color_player(id: int, color: Color):
	for i in range(button_players.size()):
		if i == id:
			button_players[i].modulate = color
		else:
			button_players[i].modulate = Color.WHITE
	
func _on_player_pressed() -> void:
	id_player = 0
	change_color_player(id_player, Color.YELLOW)
	action_selected_player(id_player)
	remove_children()
	GlobalSounds.get_node("SFX").play()
	
func _on_player_2_pressed() -> void:
	id_player = 1
	change_color_player(id_player, Color.YELLOW)
	action_selected_player(id_player)
	remove_children()
	GlobalSounds.get_node("SFX").play()
	
func _on_player_3_pressed() -> void:
	id_player = 2
	change_color_player(id_player, Color.YELLOW)
	action_selected_player(id_player)
	remove_children()
	GlobalSounds.get_node("SFX").play()
	
func target_stamina_added(text: String):
	players[2].stats.stamina -= players[2].stats.actions[0].stamina_consumed
	action_label_3.show()
	action_label_3.text = text
	selected_target(false)
	GlobalEvent.update_button.emit()
	if GlobalEvent.target_cura != -1:
		GlobalEvent.add_stamina.emit(players[2].stats.actions[0].power, GlobalEvent.target_cura)
		GlobalEvent.target_cura = -1
	
	
func _on_cure_pressed() -> void:
	GlobalEvent.target_cura = 0
	target_stamina_added("Felix stamina added")
	GlobalSounds.get_node("SFX").play()
	
func _on_cure_2_pressed() -> void:
	GlobalEvent.target_cura = 1
	target_stamina_added("Bor stamina added")
	GlobalSounds.get_node("SFX").play()

func _on_cure_3_pressed() -> void:
	GlobalEvent.target_cura = 2
	target_stamina_added("Nayeli stamina added")
	GlobalSounds.get_node("SFX").play()

func skill_consumed():
	var action_id = null
	var power_value = null
	for skill in skills:
		action_id = skill["id"]
		power_value = skill["power"]
	
		if action_id == "Fides":
			GlobalEvent.add_shield.emit(power_value)
		elif action_id != "kiss":
			GlobalEvent.update_global_state.emit(power_value)
			
	skills.clear()
	action_selected.clear()
	enemy_action_phase()

func restart_game():
	GlobalSounds.get_node("Music").play()
	id_player = 0
	progress_bar.value = 0
	start_num = 0
	shields = 0
	battle_end = false
	panel_2.hide()
	panel.show()
	turn.show()
	name_enemies.show()
	player_counter = 0
	player_emotions = ""
	skills.clear()
	action_selected.clear()
	start_off(true)
	action_button_disabled(false)
	for player in players:
		player.stats.stamina = 3
		
	for enemy in enemies:
		enemy.stats.stamina = 2
		
func _on_start_game_pressed() -> void:
	player_turn()
	restart_game()
	GlobalSounds.get_node("SFX").play()


func _on_quit_pressed() -> void:
	GlobalSounds.get_node("SFX").play()
	await get_tree().create_timer(1).timeout
	get_tree().quit()
