extends Panel
@onready var rich_text_label: RichTextLabel = $RichTextLabel
@onready var color_rect: ColorRect = $"../ColorRect"
@onready var timer: Timer = $Timer
@onready var next: Button = $Next

@export var text: Array[String]
@export var speed_typing : float = 0.05
var index = 0
var full_text: String = ""
var total_chars: int = 0
var char_index: int = 0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalEvent.end_tutorial.connect(end_tutorial)
	if text.is_empty():
		return
	
	timer.wait_time = speed_typing
	start_typing(text[index])

		
func start_typing(line_text: String):
	char_index = 0
	full_text = line_text
	total_chars = full_text.length()
	rich_text_label.visible_characters = 0
	rich_text_label.text = full_text
	timer.start()
	next.disabled = true

	

func end_tutorial():
	hide()
	color_rect.hide()


func _on_next_pressed() -> void:
	if index < text.size() - 1:
		index += 1
		start_typing(text[index])
	else:
		GlobalEvent.end_tutorial.emit()
	GlobalSounds.get_node("SFX").play()


func _on_timer_timeout() -> void:
	char_index += 1
	rich_text_label.visible_characters = char_index
	if char_index >= total_chars:
		timer.stop()
		next.disabled = false
		
