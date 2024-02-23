extends Node3D

const arena = preload("res://scenes/arena_2.tscn")

const player = preload("res://scenes/player.tscn")
const gun = preload("res://scenes/weapons/paintgun.tscn")
const bullet = preload("res://scenes/weapons/paintball.tscn")

var new_arena

var player_list = {}

var enet_peer = ENetMultiplayerPeer.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	new_arena = arena.instantiate()
	add_child(new_arena)
	




func _input(_event):
	if Input.is_action_pressed("scoreboard"):
		$CanvasLayer/ScoreBoard.show()
	else:
		$CanvasLayer/ScoreBoard.hide()


func _on_control_host_game():
	enet_peer.create_server(5555)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	$CanvasLayer/ScoreBoard.set_server_name("hosting")
	add_player(multiplayer.get_unique_id())
	$CanvasLayer/mainMenu.hide()


func _on_control_join_game(address):
	enet_peer.create_client(address, 5555)
	multiplayer.multiplayer_peer = enet_peer
	#multiplayer.connected_to_server.connect(connect_to_server)
	$CanvasLayer/ScoreBoard.set_server_name("hosting")
	$CanvasLayer/mainMenu.hide()

func add_player(peer_id):
	print("add player ", peer_id)
	var team = [Team.PURPLE, Team.GREEN][multiplayer.get_peers().size() % 2]
	var new_player = player.instantiate()
	new_player.set_name(str(peer_id))
	var spawnPoint = Vector3.ZERO
	if team == Team.GREEN:
		spawnPoint = new_arena.find_child("greenSpawn").get_children().pick_random().transform.origin
	else:
		spawnPoint = new_arena.find_child("purpleSpawn").get_children().pick_random().transform.origin
		
	add_child(new_player)
	PlayerData.set_player_name.rpc(peer_id, ["Alfa", "Bravo", "Charlie", "Delta", "Echo"].pick_random())
	PlayerData.set_player_score.rpc(peer_id, 0)
	PlayerData.set_player_team.rpc(peer_id, team)

	PlayerData.send_new_player_stats(peer_id)

	new_player.player_hit.connect(player_hit)

	await get_tree().create_timer(1.0).timeout
	new_player.equip.rpc([
		"res://scenes/weapons/minigun.tscn",
		"res://scenes/weapons/paintgun.tscn",
		"res://scenes/weapons/sniper.tscn"].pick_random())
	new_player.respawn.rpc(spawnPoint)


func remove_player(peer_id):
	PlayerData.player_disconnect.rpc(peer_id)
	var x = get_node(str(peer_id))
	x.queue_free()


@rpc("any_peer", "call_local")
func shoot_bullet_client(origin : Transform3D, velocity : Vector3, attacker_id : int):
	#print("shoot_bullet_client")
	var new_bullet = bullet.instantiate()
	new_bullet.global_transform = origin
	new_bullet.linear_velocity = velocity
	new_bullet.set_shooter(attacker_id)
	$bullets.add_child(new_bullet, true)


func player_hit(ply : Node3D, attacker_id : int):
	var victim_id = ply.name.to_int()
	print(ply, " was hit by ", attacker_id)
	$CanvasLayer/KillFeed.add_kill.rpc(attacker_id, victim_id, "")
	var spawnPoint = Vector3.ZERO
	if PlayerData.get_player_team(victim_id) == Team.GREEN:
		spawnPoint = new_arena.find_child("greenSpawn").get_children().pick_random().transform.origin
	else:
		spawnPoint = new_arena.find_child("purpleSpawn").get_children().pick_random().transform.origin
	if attacker_id != -1:
		if PlayerData.get_player_team(attacker_id) == PlayerData.get_player_team(victim_id):
			PlayerData.add_player_score.rpc(attacker_id, -1)
		else:
			PlayerData.add_player_score.rpc(attacker_id, 1)
			if PlayerData.get_player_score(attacker_id) >= 2:
				spawn_nuke.rpc(attacker_id)
	ply.equip.rpc([
		"res://scenes/weapons/minigun.tscn",
		"res://scenes/weapons/paintgun.tscn",
		"res://scenes/weapons/sniper.tscn"].pick_random())
	ply.respawn.rpc(spawnPoint)


# When the client connects to a server -> send details to server
func connect_to_server():
	# Send our preferred name to all other clients
	PlayerData.set_player_name.rpc(multiplayer.get_unique_id(), PlayerConfig.get_player_name())


@rpc("any_peer", "call_local")
func spawn_nuke(attacker_id : int):
	$CanvasLayer/GameOver.set_winner(attacker_id)
	var new_nuke = load("res://scenes/weapons/rigidNuke.tscn").instantiate()
	new_nuke.transform = new_arena.find_child("nuke_spawn").transform
	new_nuke.nuked.connect(nuke_over)
	add_child(new_nuke)


func nuke_over():
	$CanvasLayer/GameOver.show()
	var nuked_arena = load("res://scenes/arena_2_explode.tscn").instantiate()
	add_child(nuked_arena)
	$arena_2.visible = false
	await get_tree().create_timer(5).timeout
	get_tree().quit()
