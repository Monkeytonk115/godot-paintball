extends Node3D


var ticketsGreen
var ticketsPurple

func game_start():
	ticketsGreen = 100
	ticketsPurple = 100


func _on_caputure_point_entered(node):
	pass # Replace with function body.


func _on_caputure_point_exited(node):
	pass # Replace with function body.


# Timer runs every 1 second
func _on_timer_timeout():
	pass # Replace with function body.
