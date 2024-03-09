extends Node3D

const START_TICKETS : int = 100

@export var ticketsGreen : int
@export var ticketsPurple : int

@export var cp_team : int

var capture_hud

const player = preload("res://scenes/player.tscn")

var dead_players = {}

func _ready():
	# WARNING: SCUFFED
	capture_hud = get_node_or_null("/root/Main/CanvasLayer/CapturePointHud")
	assert(capture_hud, "could not find capture point HUD")

	DebugOverlay.add_property(self, "ticketsGreen", "")
	DebugOverlay.add_property(self, "ticketsPurple", "")
	DebugOverlay.add_property(self, "dead_players", "")
	DebugOverlay.add_property($RespawnWaveTimer, "time_left", "")


func _exit_tree():
	DebugOverlay.remove_property(self, "ticketsGreen")
	DebugOverlay.remove_property(self, "ticketsPurple")
	DebugOverlay.remove_property(self, "dead_players")
	DebugOverlay.remove_property($RespawnWaveTimer, "time_left")


func _process(_delta):
	capture_hud.set_green_tickets((float(ticketsGreen) / START_TICKETS) * 100.0)
	capture_hud.set_purple_tickets((float(ticketsPurple) / START_TICKETS) * 100.0)


@rpc("authority", "call_local")
func game_start():
	ticketsGreen = START_TICKETS
	ticketsPurple = START_TICKETS
	cp_team = Team.SPECTATOR
	for peer_id in PlayerData.get_connected_peers():
		spawn_player(peer_id)
	$RespawnWaveTimer.start()

# Timer runs every 2 seconds
func _on_timer_timeout():
	if not is_multiplayer_authority(): return

	# Drain the OPPOSITE team's tickets
	match cp_team:
		Team.GREEN:
			ticketsPurple = max(0, ticketsPurple - 1)
		Team.PURPLE:
			ticketsGreen = max(0, ticketsGreen - 1)
		Team.SPECTATOR:
			pass


func _on_caputure_point_captured(team):
	cp_team = team


@rpc("authority", "call_local")
func spawn_player(peer_id):
	print("spawning a player for ", peer_id)
	var spawnPoint = Vector3.ZERO
	var team = PlayerData.get_player_team(peer_id)
	if team == Team.GREEN:
		if ticketsGreen < 0:
			print("not spawning player because green has no remaining tickets")
		ticketsGreen = max(0, ticketsGreen - 1)
		spawnPoint = $greenSpawn.get_children().pick_random().transform.origin
	elif team == Team.PURPLE:
		if ticketsPurple < 0:
			print("not spawning player because purple has no remaining tickets")
		ticketsPurple = max(0, ticketsPurple - 1)
		spawnPoint = $purpleSpawn.get_children().pick_random().transform.origin
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


func player_hit(ply : Node3D, attacker_id : int):
	var victim_id = ply.name.to_int()
	print(ply, " was hit by ", attacker_id)
	get_node("/root/Main/CanvasLayer/KillFeed").add_kill.rpc(attacker_id, victim_id, "")

	if attacker_id != -1:
		if PlayerData.get_player_team(attacker_id) == PlayerData.get_player_team(victim_id):
			PlayerData.add_player_score.rpc(attacker_id, -1)
		else:
			PlayerData.add_player_score.rpc(attacker_id, 1)
	ply.queue_free()
	deathcam.rpc_id(victim_id)
	dead_players[victim_id] = 2


@rpc("any_peer", "call_local")
func spawn_nuke(attacker_id : int):
	$CanvasLayer/GameOver.set_winner(attacker_id)
	var new_nuke = load("res://scenes/weapons/rigidNuke.tscn").instantiate()
	new_nuke.transform = $nuke_spawn.transform
	new_nuke.nuked.connect(nuke_over)
	add_child(new_nuke)


func nuke_over():
	$CanvasLayer/GameOver.show()
	var nuked_arena = load("res://scenes/arena_2_explode.tscn").instantiate()
	add_child(nuked_arena)
	$arena_2.visible = false
	await get_tree().create_timer(5).timeout
	get_tree().quit()


@rpc("any_peer", "call_local")
func deathcam():
	match PlayerData.get_player_team(multiplayer.get_unique_id()):
		Team.GREEN:
			$spectator_cameras/green_01.make_current()
		Team.PURPLE:
			$spectator_cameras/purple_01.make_current()
		Team.SPECTATOR:
			print("why have we deathcammed on spectate?")
			$spectator_cameras/spectator_01.make_current()


func _on_respawn_wave_timer_timeout():
	for id in dead_players.keys():
		dead_players[id] = max(-1, dead_players[id] - 1)
		if dead_players[id] == 0:
			spawn_player(id)
			dead_players.erase(id)
	
	# Check for green losing
	if ticketsGreen == 0:
		var all_dead = true
		for id in Team.get_players(Team.GREEN):
			all_dead = all_dead and dead_players.has(id)
		if all_dead:
			spawn_nuke.rpc(PlayerData.get_highest_scorer(Team.PURPLE))
			$RespawnWaveTimer.stop()
	
	# Check for purple losing
	if ticketsPurple == 0:
		var all_dead = true
		for id in Team.get_players(Team.PURPLE):
			all_dead = all_dead and dead_players.has(id)
		if all_dead:
			spawn_nuke.rpc(PlayerData.get_highest_scorer(Team.GREEN))
			$RespawnWaveTimer.stop()

