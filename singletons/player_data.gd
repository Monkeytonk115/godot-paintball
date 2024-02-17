extends Node

var _playerNames = {}
var _scores = {}
var _teams = {}


func get_player_score(peer_id):
	return _scores.get(peer_id, 0)


@rpc("any_peer", "call_local")
func set_player_score(peer_id, score):
	_scores[peer_id] = score


@rpc("any_peer", "call_local")
func add_player_score(peer_id, score):
	_scores[peer_id] += score


func get_player_name(peer_id):
	return _playerNames.get(peer_id, "")


@rpc("any_peer", "call_local")
func set_player_name(peer_id, new_name):
	_playerNames[peer_id] = new_name


func get_connected_peers():
	var x = multiplayer.get_peers()
	x.append(multiplayer.get_unique_id())
	return x


func get_player_team(peer_id):
	return _teams.get(peer_id, Team.SPECTATOR)


@rpc("any_peer", "call_local")
func set_player_team(peer_id, team):
	_teams[peer_id] = team
