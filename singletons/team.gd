extends Node

const SPECTATOR = 0
const PURPLE = 1
const GREEN = 2


func get_players(team):
	var ply = []
	for peer_id in PlayerData.get_connected_peers():
		if PlayerData.get_player_team(peer_id) == team:
			ply.append(peer_id)
	return ply
