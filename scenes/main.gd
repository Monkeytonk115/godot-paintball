extends Node3D

const player = preload("res://scenes/player.tscn")
const bullet = preload("res://scenes/weapons/paintball.tscn")

var current_level = null

var enet_peer = ENetMultiplayerPeer.new()

var ready_players = {}

enum GameState {
	TITLE,
	LOBBY,
	GAME,
}
var game_state = GameState.TITLE

func _ready():
	# Emitted when this MultiplayerAPI's multiplayer_peer successfully connected to a server. Only emitted on clients.
	multiplayer.connected_to_server.connect(connected_to_server)
	
	# Emitted when this MultiplayerAPI's multiplayer_peer fails to establish a connection to a server. Only emitted on clients.
	multiplayer.connection_failed.connect(connection_failed)
	
	# Emitted when this MultiplayerAPI's multiplayer_peer connects with a new peer. ID is the peer ID of the new peer. Clients get notified when other clients connect to the same server. Upon connecting to a server, a client also receives this signal for the server (with ID being 1).
	multiplayer.peer_connected.connect(peer_connected)
	
	# Emitted when this MultiplayerAPI's multiplayer_peer disconnects from a peer. Clients get notified when other clients disconnect from the same server.
	multiplayer.peer_disconnected.connect(peer_disconnected)
	
	#Emitted when this MultiplayerAPI's multiplayer_peer disconnects from server. Only emitted on clients.
	multiplayer.server_disconnected.connect(server_disconnected)


func _process(delta):
	if game_state == GameState.LOBBY:
		var ready = true
		for peer_id in PlayerData.get_connected_peers():
			ready = ready and PlayerData.get_player_ready(peer_id)
		if ready:
			print("all players ready")
			$CanvasLayer/TeamSelect.hide()
			game_state = GameState.GAME
			PlayerData._ready.clear()
			for peer_id in PlayerData.get_connected_peers():
				spawn_player(peer_id)


func connected_to_server():
	# Send our preferred name to all other clients
	PlayerData.set_player_name.rpc(multiplayer.get_unique_id(), PlayerConfig.get_player_name())


# Connection to server failed
# Show the main menu again
func connection_failed():
	print("connection failed")
	$CanvasLayer/mainMenu.show()


func peer_connected(peer_id):
	print("peer connected ", peer_id)
	#PlayerData.set_player_name.rpc(peer_id, ["Alfa", "Bravo", "Charlie", "Delta", "Echo"].pick_random())
	PlayerData.set_player_score.rpc(peer_id, 0)
	PlayerData.set_player_team.rpc(peer_id, Team.SPECTATOR)
	# Update the peer with the existing player data
	PlayerData.send_new_player_stats(peer_id)
	changelevel.rpc_id(peer_id, "res://scenes/arena_2.tscn")


func peer_disconnected(peer_id):
	print("peer disconnected ", peer_id)


# Server has disconnected - show main menu
func server_disconnected():
	current_level.queue_free()
	$CanvasLayer/mainMenu.show()


@rpc("authority", "call_local")
func changelevel(new_level : String):
	print("changelevel ", new_level)
	if current_level:
		current_level.queue_free()
	current_level = load(new_level).instantiate()
	add_child(current_level)


func _input(_event):
	if Input.is_action_pressed("scoreboard"):
		$CanvasLayer/ScoreBoard.show()
	else:
		$CanvasLayer/ScoreBoard.hide()


func _on_control_host_game():
	enet_peer.create_server(5555)
	multiplayer.multiplayer_peer = enet_peer
	$CanvasLayer/ScoreBoard.set_server_name("hosting")
	PlayerData.set_player_name.rpc(multiplayer.get_unique_id(), PlayerConfig.get_player_name())
	$CanvasLayer/mainMenu.hide()
	$CanvasLayer/TeamSelect.show()
	game_state = GameState.LOBBY
	changelevel("res://scenes/arena_2.tscn")


func _on_control_join_game(address):
	enet_peer.create_client(address, 5555)
	multiplayer.multiplayer_peer = enet_peer
	$CanvasLayer/ScoreBoard.set_server_name("server: " + address)
	$CanvasLayer/TeamSelect.show()
	$CanvasLayer/mainMenu.hide()
	game_state = GameState.LOBBY


func spawn_player(peer_id):
	print("spawning a player for ", peer_id)
	var spawnPoint = Vector3.ZERO
	var team = PlayerData.get_player_team(peer_id)
	if team == Team.GREEN:
		spawnPoint = current_level.find_child("greenSpawn").get_children().pick_random().transform.origin
	elif team == Team.PURPLE:
		spawnPoint = current_level.find_child("purpleSpawn").get_children().pick_random().transform.origin
	else:
		print("can't spawn ", peer_id, " they are on spectate")
		return

	var new_player = player.instantiate()
	new_player.set_name(str(peer_id))

	$Players.add_child(new_player)
	new_player.player_hit.connect(player_hit)

	new_player.equip.rpc([
		"res://scenes/weapons/paintgun.tscn",
		"res://scenes/weapons/minigun.tscn",
		"res://scenes/weapons/sniper.tscn"].pick_random())
	new_player.respawn.rpc(spawnPoint)


func remove_player(peer_id):
	PlayerData.player_disconnect.rpc(peer_id)
	var x = $Players.get_node(str(peer_id))
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

	if attacker_id != -1:
		if PlayerData.get_player_team(attacker_id) == PlayerData.get_player_team(victim_id):
			PlayerData.add_player_score.rpc(attacker_id, -1)
		else:
			PlayerData.add_player_score.rpc(attacker_id, 1)
			if PlayerData.get_player_score(attacker_id) >= 25:
				spawn_nuke.rpc(attacker_id)
	ply.queue_free()
	deathcam.rpc_id(victim_id)
	# respawn timer
	await get_tree().create_timer(4).timeout
	spawn_player(victim_id)


@rpc("any_peer", "call_local")
func spawn_nuke(attacker_id : int):
	$CanvasLayer/GameOver.set_winner(attacker_id)
	var new_nuke = load("res://scenes/weapons/rigidNuke.tscn").instantiate()
	new_nuke.transform = current_level.find_child("nuke_spawn").transform
	new_nuke.nuked.connect(nuke_over)
	add_child(new_nuke)


func nuke_over():
	$CanvasLayer/GameOver.show()
	var nuked_arena = load("res://scenes/arena_2_explode.tscn").instantiate()
	add_child(nuked_arena)
	$arena_2.visible = false
	await get_tree().create_timer(5).timeout
	get_tree().quit()


@rpc("any_peer")
func deathcam():
	(current_level.find_child("spectator_01") as Camera3D).make_current()

