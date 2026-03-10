extends Node2D

@onready var setting_dialog = $CanvasLayer/SettingDialog


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_btn_pressed() -> void:
	pass # Replace with function body.


func _on_settings_btn_pressed() -> void:
	setting_dialog.visible = true


func _on_exit_btns_pressed() -> void:
	get_tree().quit()


func _on_close_pressed() -> void:
	setting_dialog.visible = false
