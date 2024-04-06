extends Control


func set_server_name(server_name : String):
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/ServerLabel.text = server_name


func _process(_delta):
	var green_score = 0
	for peer_id in Team.get_players(Team.GREEN):
		var x = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/GreenScore.get_node_or_null(str(peer_id))
		if x:
			var score = PlayerData.get_player_score(peer_id)
			green_score += score
			x.text = "{0} {1}".format([PlayerData.get_player_name(peer_id), PlayerData.get_player_score(peer_id)])
		else:
			var y = Label.new()
			y.set_name(str(peer_id))
			$PanelContainer/MarginContainer/VBoxContainer/GridContainer/GreenScore.add_child(y)
	$PanelContainer/MarginContainer/VBoxContainer/GridContainer/GreenScore/Label.text = "Green : {0}".format([green_score])
	
	var purple_score = 0
	for peer_id in Team.get_players(Team.PURPLE):
		var x = $PanelContainer/MarginContainer/VBoxContainer/GridContainer/PurpleScore.get_node_or_null(str(peer_id))
		if x:
			var score = PlayerData.get_player_score(peer_id)
			purple_score += score
			x.text = "{0} {1}".format([PlayerData.get_player_name(peer_id), score])
		else:
			var y = Label.new()
			y.set_name(str(peer_id))
			$PanelContainer/MarginContainer/VBoxContainer/GridContainer/PurpleScore.add_child(y)
	$PanelContainer/MarginContainer/VBoxContainer/GridContainer/PurpleScore/Label.text = "Purple : {0}".format([purple_score])
