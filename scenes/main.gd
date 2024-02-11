extends Node3D

const arena = preload("res://scenes/arena_1.tscn")
const player = preload("res://scenes/humanoid.tscn")
const gun = preload("res://scenes/paintgun.tscn")

var new_arena

# Called when the node enters the scene tree for the first time.
func _ready():
	new_arena = arena.instantiate()
	add_child(new_arena)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
