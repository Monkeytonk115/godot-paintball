extends Node3D

signal captured(team)

@export var GreenMaterial : Texture2D
@export var PurpleMaterial : Texture2D

var UncapturedMaterial : StandardMaterial3D

var pointPlayers = {}
var pointPoints = 0
var greenCount = 0
var purpleCount = 0

func _ready():
	DebugOverlay.add_property(self, "pointPoints", "")
	DebugOverlay.add_property(self, "greenCount", "")
	DebugOverlay.add_property(self, "purpleCount", "")
	var base = StandardMaterial3D.new()
	base.albedo_texture = preload("res://addons/kenney_prototype_textures/light/texture_07.png")
	base.uv1_triplanar = true
	$capture_point/Circle.set_surface_override_material(0, base)
	
	UncapturedMaterial = StandardMaterial3D.new()
	UncapturedMaterial.albedo_texture = preload("res://addons/kenney_prototype_textures/dark/texture_07.png")
	UncapturedMaterial.uv1_triplanar = true
	$capture_point/Circle.set_surface_override_material(1, base)


# Called when a player enters the capture point
func _on_area_3d_body_entered(body):
	print("entered capture point", body)
	# Player node name is their peer id
	var peer_id = body.get_name().to_int()
	pointPlayers[peer_id] = true
	_update_playercount()


# Called when a player leaves the capture point
func _on_area_3d_body_exited(body):
	print("exited capture point", body)
	# Player node name is their peer id
	var peer_id = body.get_name().to_int()
	pointPlayers.erase(peer_id)
	_update_playercount()


func _update_playercount():
	var g = 0
	var p = 0
	for ply in pointPlayers.keys():
		match PlayerData.get_player_team(ply):
			Team.GREEN:
				g += 1
			Team.PURPLE:
				p += 1
			Team.SPECTATOR:
				assert(0, "spectators cannot capture points")
	greenCount = g
	purpleCount = p


func team_captured(team):
	match team:
		Team.GREEN:
			$capture_point/Circle.set_surface_override_material(1, GreenMaterial)
		Team.PURPLE:
			$capture_point/Circle.set_surface_override_material(1, PurpleMaterial)
		Team.SPECTATOR:
			print("spectator capturing the point - neither team has the point")
			$capture_point/Circle.set_surface_override_material(1, UncapturedMaterial)


func _process(delta):
	match [greenCount, purpleCount]:
		[0, 0]:
			#print("nobody on point")
			pass
		[var g, 0]:
			#print(g, " green players")
			pointPoints = min(pointPoints + (_player_to_speed(g) * delta), 20)
		[0, var p]:
			#print(p, " purple players")
			pointPoints = max(pointPoints - (_player_to_speed(p) * delta), -20)
		[var g, var p]:
			#print(g, " green players and ", p, " purple players")
			pass
	#print(pointPoints)


func _exit_tree():
	DebugOverlay.remove_property(self, "pointPoints")
	DebugOverlay.remove_property(self, "greenCount")
	DebugOverlay.remove_property(self, "purpleCount")


func _player_to_speed(player_count : int):
	if player_count < 0:
		return 0
	if player_count < 7:
		return [0, 1, 1.5, 1.8, 2, 2.2, 2.45][player_count]
	return 2.45
