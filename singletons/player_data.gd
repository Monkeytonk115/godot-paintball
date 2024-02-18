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


@rpc("any_peer", "call_local")
func player_disconnect(peer_id):
	_playerNames.erase(peer_id)
	_scores.erase(peer_id)
	_teams.erase(peer_id)


# This function sends all currently connected player infos to new connected player
func send_new_player_stats(peer_id):
	for k in _playerNames.keys():
		set_player_name.rpc_id(peer_id, k, _playerNames[k])
	for k in _scores.keys():
		set_player_score.rpc_id(peer_id, k, _scores[k])
	for k in _teams.keys():
		set_player_team.rpc_id(peer_id, k, _teams[k])
