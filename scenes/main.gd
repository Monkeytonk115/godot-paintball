extends Node3D

const arena = preload("res://scenes/arena_1.tscn")
const arena2 = preload("res://scenes/arena_2.tscn")
const player = preload("res://scenes/player.tscn")
const gun = preload("res://scenes/weapons/paintgun.tscn")
const bullet = preload("res://scenes/weapons/paintball.tscn")

var new_arena

var player_list = {}

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
	
	var new_gun = gun.instantiate()
	new_gun.shoot_bullet.connect(shoot_bullet)
	new_player.equip(new_gun)
	var spawnPoint = new_arena.find_child("purpleSpawn").get_children().pick_random()
	add_child(new_player)
	new_player.global_transform = spawnPoint.global_transform


func remove_player(peer_id):
	pass



func shoot_bullet(origin : Transform3D, velocity : Vector3):
	print("shoot_bullet")
	# call on all clients so they spawn a bullet
	shoot_bullet_client.rpc(origin, velocity)


@rpc("any_peer", "call_local")
func shoot_bullet_client(origin : Transform3D, velocity : Vector3):
	print("shoot_bullet_client")
	var new_bullet = bullet.instantiate()
	new_bullet.global_transform = origin
	new_bullet.linear_velocity = velocity
	$bullets.add_child(new_bullet, true)
