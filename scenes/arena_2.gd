extends Node3D


var ticketsGreen
var ticketsPurple

func game_start():
	ticketsGreen = 100
	ticketsPurple = 100


# Timer runs every 1 second
func _on_timer_timeout():
	pass # Replace with function body.


func _on_caputure_point_captured(team):
	pass # Replace with function body.
