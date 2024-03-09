extends Node3D

const bullet = preload("res://scenes/weapons/paintball.tscn")

var current_level = null

var enet_peer = ENetMultiplayerPeer.new()

var ready_players = {}

var voice_id : String = ""

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


	var voices = DisplayServer.tts_get_voices_for_language("en")
	if len(voices) > 0:
		voice_id = voices[0]


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
			if multiplayer.is_server():
				current_level.game_start.rpc()


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
	# Server has peer id 1
	if (peer_id == 1):
		# If we disconnect from server, set the multiplayer_peer to null
		# This disconnects networking and we can return to the main menu
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null
		
		# Close the current level and return to the main menu
		if current_level:
			current_level.queue_free()
		PlayerData.clear_data()
		$CanvasLayer/TeamSelect.hide()
		$CanvasLayer/GameOver.hide()
		$CanvasLayer/ScoreBoard.hide()
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
	$CanvasLayer/CapturePointHud.show()
	game_state = GameState.LOBBY
	changelevel("res://scenes/arena_2.tscn")


func _on_control_join_game(address):
	enet_peer.create_client(address, 5555)
	multiplayer.multiplayer_peer = enet_peer
	$CanvasLayer/ScoreBoard.set_server_name("server: " + address)
	$CanvasLayer/TeamSelect.show()
	$CanvasLayer/mainMenu.hide()
	$CanvasLayer/CapturePointHud.show()
	game_state = GameState.LOBBY


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
