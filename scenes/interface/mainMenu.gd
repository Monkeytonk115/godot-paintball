extends Control
signal hostGame
signal joinGame(address)

const titleScreen = preload("res://scenes/interface/titleScreen.tscn")
var new_titleScreen

# Called when the node enters the scene tree for the first time.
func _ready():
	$PanelContainer/MarginContainer/VBoxContainer/LineEdit2.text = PlayerConfig.get_player_name()
	new_titleScreen = titleScreen.instantiate()
	add_child(new_titleScreen)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_button_pressed():
	hostGame.emit()
	new_titleScreen.queue_free()


func _on_button_2_pressed():
	joinGame.emit($PanelContainer/MarginContainer/VBoxContainer/LineEdit.text)
	new_titleScreen.queue_free()


func _on_line_edit_2_text_changed(new_text):
	PlayerConfig.set_player_name(new_text)
