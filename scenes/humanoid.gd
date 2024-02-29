extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var team = PlayerData.get_player_team(get_parent().get_name())
	var material = StandardMaterial3D.new()
	
	if team == 0:
		material.albedo_color = Color(0.75, 0, 1)
		$body.set_surface_override_material(0, material)
	if team == 1:
		material.albedo_color = Color(0, 1, 0)
		$body.set_surface_override_material(0, material)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
