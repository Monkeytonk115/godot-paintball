extends Node3D

signal nuke_over

const nuke = preload("res://scenes/weapons/rigidNuke.tscn")


@rpc("authority", "call_local")
func spawn_nuke():
	var new_nuke = load("res://scenes/weapons/rigidNuke.tscn").instantiate()
	new_nuke.nuked.connect(func(): nuke_over.emit())
	add_child(new_nuke)
