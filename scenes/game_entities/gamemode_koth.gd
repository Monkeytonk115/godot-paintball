extends Node3D

@export var capture_point_path : NodePath

var capture_point = null
var capture_hud = null
var teammate_hud = null


func _ready():
	capture_point = get_node_or_null(capture_point_path)
	assert(capture_point, "could not find capture point")
	
	# WARNING: SCUFFED
	capture_hud = get_node_or_null("/root/Main/CanvasLayer/CapturePointHud")
	assert(capture_hud, "could not find capture point HUD")

	teammate_hud = get_node_or_null("/root/Main/CanvasLayer/TeammateHud")
	assert(teammate_hud, "could not find teammate HUD")
	
	$RespawnWaveTimerGreen.start(6)
	$RespawnWaveTimerPurple.start(6)


func _process(delta):
	pass


func _on_respawn_wave_timer_green_timeout():
	pass # Replace with function body.


func _on_respawn_wave_timer_purple_timeout():
	pass # Replace with function body.


func _on_ticket_timer_timeout():
	pass # Replace with function body.
