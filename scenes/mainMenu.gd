extends Control
signal hostGame
signal joinGame(address)

const titleScreen = preload("res://scenes/titleScreen.tscn")
var new_titleScreen

# Called when the node enters the scene tree for the first time.
func _ready():
	new_titleScreen = titleScreen.instantiate()
	add_child(new_titleScreen)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	hostGame.emit()
	new_titleScreen.queue_free()


func _on_button_2_pressed():
	joinGame.emit($PanelContainer/MarginContainer/VBoxContainer/LineEdit.text)
	new_titleScreen.queue_free()
