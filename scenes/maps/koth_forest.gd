extends Node3D

@rpc("authority", "call_local")
func game_start():
	for peer_id in PlayerData.get_connected_peers():
		GameData.set_player_spawn_wave(peer_id, 1)
	$GamemodeKoth.game_start()


func nuke_over():
	$arena_3.hide()

	get_node("/root/Main/CanvasLayer/GameOver").show()
	var nuked_arena = load("res://scenes/maps/arena_2_explode.tscn").instantiate()
	add_child(nuked_arena)

	await get_tree().create_timer(5).timeout
	get_tree().quit()


func _on_gamemode_koth_team_win(team, mvp):
	get_node("/root/Main/CanvasLayer/GameOver").set_winner.rpc(mvp)
	$NukeSpawner.spawn_nuke.rpc()
