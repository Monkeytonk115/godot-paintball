extends Control


func set_server_name(server_name : String):
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ServerLabel.text = server_name


func _process(_delta):
	for peer_id in Team.get_players(Team.GREEN):
		var x = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/GreenScore.get_node(str(peer_id))
		if x:
			x.text = "{0} {1} {2}".format([peer_id, PlayerData.get_player_name(peer_id), PlayerData.get_player_score(peer_id)])
		else:
			var y = Label.new()
			y.set_name(str(peer_id))
			$PanelContainer/MarginContainer/VBoxContainer/GridContainer/GreenScore.add_child(y)

	for peer_id in Team.get_players(Team.PURPLE):
		var x = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/PurpleScore.get_node(str(peer_id))
		if x:
			x.text = "{0} {1} {2}".format([peer_id, PlayerData.get_player_name(peer_id), PlayerData.get_player_score(peer_id)])
		else:
			var y = Label.new()
			y.set_name(str(peer_id))
			$PanelContainer/MarginContainer/VBoxContainer/GridContainer/PurpleScore.add_child(y)
