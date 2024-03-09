extends Node3D

const START_TICKETS : int = 100

@export var ticketsGreen : int
@export var ticketsPurple : int

@export var cp_team : int

var capture_hud

func _ready():
	# WARNING: SCUFFED
	capture_hud = get_node_or_null("/root/Main/CanvasLayer/CapturePointHud")
	assert(capture_hud, "could not find capture point HUD")

	DebugOverlay.add_property(self, "ticketsGreen", "")
	DebugOverlay.add_property(self, "ticketsPurple", "")


func _process(_delta):
	capture_hud.set_green_tickets((float(ticketsGreen) / START_TICKETS) * 100.0)
	capture_hud.set_purple_tickets((float(ticketsPurple) / START_TICKETS) * 100.0)


@rpc("authority", "call_local")
func game_start():
	ticketsGreen = START_TICKETS
	ticketsPurple = START_TICKETS
	cp_team = Team.SPECTATOR


# Timer runs every 2 seconds
func _on_timer_timeout():
	if not is_multiplayer_authority(): return

	# Drain the OPPOSITE team's tickets
	match cp_team:
		Team.GREEN:
			ticketsPurple = max(0, ticketsPurple - 1)
		Team.PURPLE:
			ticketsGreen = max(0, ticketsGreen - 1)
		Team.SPECTATOR:
			pass


func _on_caputure_point_captured(team):
	cp_team = team
