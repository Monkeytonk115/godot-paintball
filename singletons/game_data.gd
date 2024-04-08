extends Node

const player = preload("res://scenes/player.tscn")


var current_level = null
var respawning_players = {}

func _ready():
	DebugOverlay.add_property(self, "respawning_players", "")
	

func is_player_alive(peer_id):
	return not respawning_players.has(peer_id)


func set_player_spawn_wave(peer_id, respawn_wave):
	respawning_players[peer_id] = respawn_wave


func get_spawn_wave(peer_id):
	return respawning_players.get(peer_id, -1)


func reduce_spawn_wave(peer_id):
	respawning_players[peer_id] = max(0, respawning_players.get(peer_id, 0) - 1)


func get_spawns_for_team(team):
	match team:
		Team.GREEN:
			return current_level.get_node("greenSpawn").get_children()
		Team.PURPLE:
			return current_level.get_node("purpleSpawn").get_children()
	return []


func spawn_player(peer_id):
	print("spawning a player for ", peer_id)
	
	var spawnPoint = Vector3.ZERO
	var spawns = get_spawns_for_team(PlayerData.get_player_team(peer_id))
	spawnPoint = spawns.pick_random().transform.origin

	respawning_players.erase(peer_id)

	var new_player = player.instantiate()
	new_player.set_name(str(peer_id))

	current_level.get_node("Players").add_child(new_player)
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
	set_player_spawn_wave(victim_id, 2)


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
