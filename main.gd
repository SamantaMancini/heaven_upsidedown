extends Node2D
@onready var label_3: Label = $Label3
@onready var label_5: Label = $Label5
@onready var progress_bar: ProgressBar = $ProgressBar
@export var start_num : int = 0
var shields = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_3.text = str(start_num)
	label_5.text = str(shields)
	GlobalEvent.update_global_state.connect(add_points)
	GlobalEvent.add_shield.connect(add_shield)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if progress_bar.value <= progress_bar.min_value:
		print("GAME OVER")
	if progress_bar.value >= progress_bar.max_value:
		print("WINNER")
	label_3.text = str(start_num)
	label_5.text = str(shields)
	
func add_points(value: float):
	progress_bar.value += value
	start_num += value

func add_shield(shield: float):
	shields += shield
	
func _on_button_pressed() -> void:
	if shields == 0:
		if progress_bar.value > progress_bar.min_value:
			progress_bar.value -= 1
			start_num -= 1
	else:
		shields -= 1
		
