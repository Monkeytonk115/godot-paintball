extends Control


@onready var spectator_players = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/SpectatorPlayers
@onready var join_spectator = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer3/JoinSpectator

@onready var green_players = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/GreenPlayers
@onready var join_green = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/JoinGreen

@onready var purple_players = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/PurplePlayers
@onready var join_purple = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/JoinPurple

@onready var ready_up = $PanelContainer/MarginContainer/VBoxContainer/ReadyUp


func _process(_delta):
	for peer_id in Team.get_players(Team.GREEN):
		var x = green_players.get_node_or_null(str(peer_id))
		if x:
			x.text = "{0} [{1}]".format([PlayerData.get_player_name(peer_id), PlayerData.get_player_ready(peer_id)])
		else:
			var y = Label.new()
			y.set_name(str(peer_id))
			green_players.add_child(y)
		var z = purple_players.get_node_or_null(str(peer_id))
		if z:
			z.queue_free()
		var w = spectator_players.get_node_or_null(str(peer_id))
		if w:
			w.queue_free()
	
	for peer_id in Team.get_players(Team.PURPLE):
		var x = purple_players.get_node_or_null(str(peer_id))
		if x:
			x.text = "{0} [{1}]".format([PlayerData.get_player_name(peer_id), PlayerData.get_player_ready(peer_id)])
		else:
			var y = Label.new()
			y.set_name(str(peer_id))
			purple_players.add_child(y)
		var z = green_players.get_node_or_null(str(peer_id))
		if z:
			z.queue_free()
		var w = spectator_players.get_node_or_null(str(peer_id))
		if w:
			w.queue_free()
	
	for peer_id in Team.get_players(Team.SPECTATOR):
		var x = spectator_players.get_node_or_null(str(peer_id))
		if x:
			x.text = "{0} [{1}]".format([PlayerData.get_player_name(peer_id), PlayerData.get_player_ready(peer_id)])
		else:
			var y = Label.new()
			y.set_name(str(peer_id))
			spectator_players.add_child(y)
		var z = purple_players.get_node_or_null(str(peer_id))
		if z:
			z.queue_free()
		var w = green_players.get_node_or_null(str(peer_id))
		if w:
			w.queue_free()


func _on_join_green_pressed():
	PlayerData.set_player_team.rpc(multiplayer.get_unique_id(), Team.GREEN)
	ready_up.disabled = false

func _on_join_purple_pressed():
	PlayerData.set_player_team.rpc(multiplayer.get_unique_id(), Team.PURPLE)
	ready_up.disabled = false


func _on_button_pressed():
	join_spectator.disabled = true
	join_green.disabled = true
	join_purple.disabled = true
	ready_up.disabled = true
	PlayerData.set_player_ready.rpc(multiplayer.get_unique_id(), true)
