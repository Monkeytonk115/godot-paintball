extends Node3D

const arena = preload("res://scenes/arena_1.tscn")
const arena2 = preload("res://scenes/arena_2.tscn")
const player = preload("res://scenes/player.tscn")
const gun = preload("res://scenes/weapons/paintgun.tscn")

var new_arena

var enet_peer = ENetMultiplayerPeer.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	new_arena = arena2.instantiate()
	add_child(new_arena)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_control_host_game():
	enet_peer.create_server(5555)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	add_player(multiplayer.get_unique_id())
	$CanvasLayer/mainMenu.hide()


func _on_control_join_game(address):
	enet_peer.create_client(address, 5555)
	multiplayer.multiplayer_peer = enet_peer
	$CanvasLayer/mainMenu.hide()

func add_player(peer_id):
	print("add player ", peer_id) 
	var new_player = player.instantiate()
	new_player.set_name(str(peer_id))
	new_player.equip(gun)
	var spawnPoint = new_arena.find_child("purpleSpawn").get_children().pick_random()
	new_player.global_transform = spawnPoint.global_transform
	add_child(new_player)


func remove_player(peer_id):
	pass
