extends Node3D

@export var GreenMaterial : Texture2D
@export var PurpleMaterial : Texture2D

var UncapturedMaterial : StandardMaterial3D

func _ready():
	var base = StandardMaterial3D.new()
	base.albedo_texture = preload("res://addons/kenney_prototype_textures/light/texture_07.png")
	base.uv1_triplanar = true
	$capture_point/Circle.set_surface_override_material(0, base)
	
	UncapturedMaterial = StandardMaterial3D.new()
	UncapturedMaterial.albedo_texture = preload("res://addons/kenney_prototype_textures/dark/texture_07.png")
	UncapturedMaterial.uv1_triplanar = true
	$capture_point/Circle.set_surface_override_material(1, base)


func _on_area_3d_body_entered(body):
	print("entered capture point", body)


func _on_area_3d_body_exited(body):
	print("exited capture point", body)


func team_captured(team):
	match team:
		Team.GREEN:
			$capture_point/Circle.set_surface_override_material(1, GreenMaterial)
		Team.PURPLE:
			$capture_point/Circle.set_surface_override_material(1, PurpleMaterial)
		Team.SPECTATOR:
			print("spectator capturing the point - neither team has the point")
			$capture_point/Circle.set_surface_override_material(1, UncapturedMaterial)
