extends Control


func set_winner(winning_player):
	var winning_team = PlayerData.get_player_team(winning_player)
	if winning_team == Team.GREEN:
		$PanelContainer/MarginContainer/Label.text = "Green team wins\nMVP: {0}".format([PlayerData.get_player_name(winning_player)])
	else:
		$PanelContainer/MarginContainer/Label.text = "Purple team wins\nMVP: {0}".format([PlayerData.get_player_name(winning_player)])
