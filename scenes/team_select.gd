extends Control

signal player_ready

func _process(_delta):
	for peer_id in Team.get_players(Team.GREEN):
		var x = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/GreenPlayers.get_node_or_null(str(peer_id))
		if x:
			x.text = "{0} [{1}]".format([PlayerData.get_player_name(peer_id), PlayerData.get_player_ready(peer_id)])
		else:
			var y = Label.new()
			y.set_name(str(peer_id))
			$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/GreenPlayers.add_child(y)
	
	for peer_id in Team.get_players(Team.PURPLE):
		var x = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/PurplePlayers.get_node_or_null(str(peer_id))
		if x:
			x.text = "{0} [{1}]".format([PlayerData.get_player_name(peer_id), PlayerData.get_player_ready(peer_id)])
		else:
			var y = Label.new()
			y.set_name(str(peer_id))
			$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/PurplePlayers.add_child(y)



func _on_join_green_pressed():
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/JoinGreen.disabled = true
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/JoinPurple.disabled = true
	PlayerData.set_player_team.rpc(multiplayer.get_unique_id(), Team.GREEN)
	$PanelContainer/MarginContainer/VBoxContainer/Button.disabled = false

func _on_join_purple_pressed():
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/JoinGreen.disabled = true
	$PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/JoinPurple.disabled = true
	PlayerData.set_player_team.rpc(multiplayer.get_unique_id(), Team.PURPLE)
	$PanelContainer/MarginContainer/VBoxContainer/Button.disabled = false


func _on_button_pressed():
	$PanelContainer/MarginContainer/VBoxContainer/Button.disabled = true
	PlayerData.set_player_ready.rpc(multiplayer.get_unique_id(), true)
