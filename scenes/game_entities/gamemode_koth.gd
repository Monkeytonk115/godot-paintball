extends Node3D

signal ticket_changed(team, tickets)
signal team_win(team, mvp)


@export var capture_point_path : NodePath

const START_TICKETS : int = 100

@export var ticketsGreen : int
@export var ticketsPurple : int

var cp_team = Team.SPECTATOR

func _ready():
	DebugOverlay.add_property(self, "ticketsGreen", "")
	DebugOverlay.add_property(self, "ticketsPurple", "")
	DebugOverlay.add_property($RespawnWaveTimerGreen, "time_left", "")
	DebugOverlay.add_property($RespawnWaveTimerPurple, "time_left", "")


func _exit_tree():
	DebugOverlay.remove_property(self, "ticketsGreen")
	DebugOverlay.remove_property(self, "ticketsPurple")
	DebugOverlay.remove_property($RespawnWaveTimerGreen, "time_left")
	DebugOverlay.remove_property($RespawnWaveTimerPurple, "time_left")


func game_start():
	if not is_multiplayer_authority(): return
	$RespawnWaveTimerGreen.start(6)
	$RespawnWaveTimerPurple.start(6)
	$TicketTimer.start(2)


func _on_respawn_wave_timer_green_timeout():
	if !is_multiplayer_authority(): return

	for id in Team.get_players(Team.GREEN):
		if GameData.is_player_alive(id):
			pass
		else:
			GameData.reduce_spawn_wave(id)
			if GameData.get_spawn_wave(id) == 0:
				GameData.spawn_player(id)
	
	if ticketsGreen == 0:
		team_win.emit(Team.PURPLE, PlayerData.get_highest_scorer(Team.PURPLE))
		$RespawnWaveTimerGreen.stop()
		$RespawnWaveTimerPurple.stop()


func _on_respawn_wave_timer_purple_timeout():
	if !is_multiplayer_authority(): return

	for id in Team.get_players(Team.PURPLE):
		if GameData.is_player_alive(id):
			pass
		else:
			GameData.reduce_spawn_wave(id)
			if GameData.get_spawn_wave(id) == 0:
				GameData.spawn_player(id)

	if ticketsPurple == 0:
		team_win.emit(Team.GREEN, PlayerData.get_highest_scorer(Team.GREEN))
		$RespawnWaveTimerGreen.stop()
		$RespawnWaveTimerPurple.stop()


func _on_ticket_timer_timeout():
	if not is_multiplayer_authority(): return

	# Drain the OPPOSITE team's tickets
	match cp_team:
		Team.GREEN:
			ticketsPurple = max(0, ticketsPurple - 1)
			ticket_changed.emit(Team.PURPLE, ticketsPurple)
		Team.PURPLE:
			ticketsGreen = max(0, ticketsGreen - 1)
			ticket_changed.emit(Team.GREEN, ticketsGreen)
		Team.SPECTATOR:
			pass


func _on_caputure_point_captured(team):
	print("_on_caputure_point_captured ", team)
	if not is_multiplayer_authority(): return

	cp_team = team
	match team:
		Team.GREEN:
			$RespawnWaveTimerGreen.set_wait_time(6)
			$RespawnWaveTimerPurple.set_wait_time(4)
		Team.PURPLE:
			$RespawnWaveTimerGreen.set_wait_time(4)
			$RespawnWaveTimerPurple.set_wait_time(6)
		Team.SPECTATOR:
			pass
