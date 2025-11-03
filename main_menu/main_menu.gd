extends Control
@onready var v_box_container: VBoxContainer = $VBoxContainer
@onready var v_box_container_2: VBoxContainer = $VBoxContainer2
@onready var title: Label = $Title
@export var level : PackedScene


func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(level)
	GlobalSounds.get_node("SFX").play()


func _on_settings_pressed() -> void:
	v_box_container.hide()
	v_box_container_2.show()
	title.text = "Settings"
	GlobalSounds.get_node("SFX").play()


func _on_back_pressed() -> void:
	v_box_container.show()
	v_box_container_2.hide()
	title.text = "Heaven UpsideDown"
	GlobalSounds.get_node("SFX").play()


func _on_quit_pressed() -> void:
	get_tree().quit()
	GlobalSounds.get_node("SFX").play()
