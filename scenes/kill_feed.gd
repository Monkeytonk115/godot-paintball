extends Control

@rpc("any_peer", "call_local")
func add_kill(attacker_id, victim_id, _weapon):
	var l = Label.new()
	l.text = "{0} killed {1}".format([PlayerData.get_player_name(attacker_id), PlayerData.get_player_name(victim_id)])
	$MarginContainer/VBoxContainer.add_child(l)
	await get_tree().create_timer(2).timeout
	l.queue_free()
