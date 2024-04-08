extends Node3D


@rpc("authority", "call_local")
func game_start():
	for peer_id in PlayerData.get_connected_peers():
		GameData.set_player_spawn_wave(peer_id, 1)
	$GamemodeKoth.game_start()


func nuke_over():
	get_node("/root/Main/CanvasLayer/GameOver").show()
	var nuked_arena = load("res://scenes/maps/arena_2_explode.tscn").instantiate()
	add_child(nuked_arena)
	for x in [$Cube_012b, $Cube, $Cube_011, $Cube_010, $Cube_012, $Cube_013, $Cube_014, $Cube_015, $Cube_016, $Cube_017, $Cube_018, $Cube_019, $Cube_020, $Cube_021]:
		x.hide()
	await get_tree().create_timer(5).timeout
	get_tree().quit()


func _on_gamemode_koth_team_win(team, mvp):
	get_node("/root/Main/CanvasLayer/GameOver").set_winner.rpc(mvp)
	$NukeSpawner.spawn_nuke.rpc()
