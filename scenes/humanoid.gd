extends Node3D


func set_shirt_color(c : Color):
	var material = StandardMaterial3D.new()
	material.albedo_color = c
	$body.set_surface_override_material(0, material)
