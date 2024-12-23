extends Node3D

signal captured(team)

@export var GreenMaterial : StandardMaterial3D
@export var PurpleMaterial : StandardMaterial3D

var UncapturedMaterial : StandardMaterial3D

# Players on the capture point
var pointPlayers = {}
var greenCount = 0
var purpleCount = 0

# Capture progress variables
var greenCapture = 0
var purpleCapture = 0

var _team = Team.SPECTATOR

var capture_hud

func _ready():
	DebugOverlay.add_property(self, "greenCount", "")
	DebugOverlay.add_property(self, "purpleCount", "")
	
	DebugOverlay.add_property(self, "greenCapture", "")
	DebugOverlay.add_property(self, "purpleCapture", "")
	
	# WARNING: SCUFFED
	capture_hud = get_node_or_null("/root/Main/CanvasLayer/CapturePointHud")
	assert(capture_hud, "could not find capture point HUD")

	_team = Team.SPECTATOR

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
	# Player node name is their peer id
	var peer_id = body.get_name().to_int()
	pointPlayers[peer_id] = true
	_update_playercount()


# Called when a player leaves the capture point
func _on_area_3d_body_exited(body):
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
	self._team = team
	self.greenCapture = 0
	self.purpleCapture = 0
	match team:
		Team.GREEN:
			$capture_point/Circle.set_surface_override_material(1, GreenMaterial)
		Team.PURPLE:
			$capture_point/Circle.set_surface_override_material(1, PurpleMaterial)
		Team.SPECTATOR:
			$capture_point/Circle.set_surface_override_material(1, UncapturedMaterial)
	captured.emit(team)


func _process(delta):
	match [greenCount, purpleCount]:
		[0, 0]:
			# If nobody is standing on the point, then capture progress decreases to 0 for both
			# They decrease by 0.5 per second
			greenCapture  = max(0, greenCapture  - (0.5 * delta))
			purpleCapture = max(0, purpleCapture - (0.5 * delta))
		[var g, 0]:
			# Only green players on the point decreases purple's capture progress
			# We add 1 to the player count to give uncapturing progress a little more speed
			purpleCapture = max(0, purpleCapture - (_player_to_speed(g + 1) * delta))
			# If purple's capture progress is 0
			# and Green team does NOT own the capture point
			# then we also increase green's capture progress
			if (purpleCapture < 0.01) and (self._team != Team.GREEN):
				greenCapture = min(20, greenCapture + (_player_to_speed(g) * delta))
				if (greenCapture > 19.99):
					team_captured(Team.GREEN)
		[0, var p]:
			# Only purple players on the point decreases green's capture progress
			# We add 1 to the player count to give uncapturing progress a little more speed
			greenCapture = max(0, greenCapture - (_player_to_speed(p + 1) * delta))
			# If green's capture progress is 0
			# and Purple team does NOT own the capture point
			# then we also increase purple's capture progress
			if (greenCapture < 0.01) and (self._team != Team.PURPLE):
				purpleCapture = min(20, purpleCapture + (_player_to_speed(p) * delta))
				if (purpleCapture > 19.99):
					team_captured(Team.PURPLE)
		[var g, var p]:
			# If both teams are standing then capture progress does not change
			pass
	if greenCapture > 0.01:
		capture_hud.set_capture_value(greenCapture * 5, self._team, Team.GREEN)
	elif purpleCapture > 0.01:
		capture_hud.set_capture_value(purpleCapture * 5, self._team, Team.PURPLE)
	else:
		capture_hud.set_capture_value(0, self._team, Team.SPECTATOR)


func _exit_tree():
	DebugOverlay.remove_property(self, "greenCount")
	DebugOverlay.remove_property(self, "purpleCount")
	
	DebugOverlay.remove_property(self, "greenCapture")
	DebugOverlay.remove_property(self, "purpleCapture")


func _player_to_speed(player_count : int):
	if player_count < 0:
		return 0
	if player_count < 7:
		return [0, 1, 1.5, 1.8, 2, 2.2, 2.45][player_count]
	return 2.45
