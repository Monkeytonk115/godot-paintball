extends Control


func update_hud(dead_players):
	for peer_id in Team.get_players(Team.GREEN):
		var x = $GreenPlayers.get_node_or_null(str(peer_id))
		if x:
			if dead_players.has(peer_id):
				x.text = "💀 {0}".format([PlayerData.get_player_name(peer_id)])
			else:
				x.text = "{0}".format([PlayerData.get_player_name(peer_id)])
		else:
			var y = Label.new()
			y.set_name(str(peer_id))
			$GreenPlayers.add_child(y)


	var purple_score = 0
	for peer_id in Team.get_players(Team.PURPLE):
		var x = $PurplePlayers.get_node_or_null(str(peer_id))
		if x:
			if dead_players.has(peer_id):
				x.text = "💀 {0}".format([PlayerData.get_player_name(peer_id)])
			else:
				x.text = "{0}".format([PlayerData.get_player_name(peer_id)])
		else:
			var y = Label.new()
			y.set_name(str(peer_id))
			$PurplePlayers.add_child(y)
