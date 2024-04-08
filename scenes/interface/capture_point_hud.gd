extends Control


@export var neutral : StyleBoxFlat
@export var green : StyleBoxFlat
@export var purple : StyleBoxFlat


func update_tickets(team, tickets):
	match team:
		Team.GREEN:
			$MarginContainer/HBoxContainer/GreenTickets.value = tickets
		Team.PURPLE:
			$MarginContainer/HBoxContainer/PurpleTickets.value = tickets


func set_capture_value(capture_value, current_team, new_team):
	var cp = ($MarginContainer/HBoxContainer/CapturePoint as ProgressBar)
	match current_team:
		Team.GREEN:
			cp.add_theme_stylebox_override("background", green)
		Team.PURPLE:
			cp.add_theme_stylebox_override("background", purple)
		Team.SPECTATOR:
			cp.add_theme_stylebox_override("background", neutral)
	
	match new_team:
		Team.GREEN:
			cp.add_theme_stylebox_override("fill", green)
		Team.PURPLE:
			cp.add_theme_stylebox_override("fill", purple)
		Team.SPECTATOR:
			cp.add_theme_stylebox_override("fill", neutral)
	cp.value = capture_value
