extends Node2D
@onready var label_3: Label = $Label3
@onready var label_5: Label = $Label5
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var button_4: Button = $Button4
@onready var button_3: Button = $Button3
@onready var button_5: Button = $Button5
@onready var button_6: Button = $Button6
@onready var button_7: Button = $Button7
@export var start_num : int = 0
@export var combination_1 : String
@export var combination_2 : String
@export var players : Array[Player]

var shields = 0
var player_emotions = []
var skills : Dictionary = {}
var target_name : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_3.text = str(start_num)
	label_5.text = str(shields)
	GlobalEvent.update_global_state.connect(add_points)
	GlobalEvent.add_shield.connect(add_shield)
	GlobalEvent.combination.connect(dance_group)
	GlobalEvent.update_button.connect(update_button)
	GlobalEvent.combination_2.connect(hug_group)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if progress_bar.value <= progress_bar.min_value:
		print("GAME OVER")
	if progress_bar.value >= progress_bar.max_value:
		print("WINNER")
	label_3.text = str(start_num)
	label_5.text = str(shields)
	button_4.text = " ".join(player_emotions)
		
func update_button():
	for player in players:
		if not player_emotions.has(player.emotions):
			player_emotions.append(player.emotions)
	
	button_4.text = " ".join(player_emotions)
	button_3.text = " ".join(player_emotions)
	
func add_points(value: float):
	progress_bar.value += value
	start_num += value
#
func add_shield(shield: float):
	shields += shield

func dance_group(comb: String):
	if comb == combination_1:
		progress_bar.value += 5
		start_num += 5
	
func hug_group(comb: String, stamina: float):
	for player in players:
		if comb == combination_2:
			player.add_stamina_group(stamina)
		
func _on_button_pressed() -> void:
	if shields == 0:
		if progress_bar.value > progress_bar.min_value:
			progress_bar.value -= 1
			start_num -= 1
	else:
		shields -= 1
		

func _on_button_2_pressed() -> void:
	GlobalEvent.start_process.emit()


func _on_button_4_pressed() -> void:
	GlobalEvent.combination.emit(" ".join(player_emotions))
	player_emotions.clear()
	skills.clear()
	for player in players:
		player.emotions = ""
		player.skill_consumed = []
	


func _on_button_3_pressed() -> void:
	GlobalEvent.combination_2.emit(" ".join(player_emotions), 5)
	player_emotions.clear()
	skills.clear()
	for player in players:
		player.emotions = ""
		player.skill_consumed = []


func _on_button_5_pressed() -> void:
	for player in players:
		GlobalEvent.target_cura = player.stats.id
		player.target_on = false

#Difensore
func _on_button_6_pressed() -> void:
	GlobalEvent.target_cura = 1
	for player in players:
		#GlobalEvent.target_cura = player.stats.id
		player.target_on = false


func _on_button_7_pressed() -> void:
	for player in players:
		GlobalEvent.target_cura = player.stats.id
		player.target_on = false
