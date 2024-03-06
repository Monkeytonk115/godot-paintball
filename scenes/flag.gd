extends Node3D

signal picked(team)
signal dropped(team)
signal returned(team)
signal captured(team)


var _team
var _spawn : Transform3D

var holder

func _ready():
	holder = null


func _physics_process(delta):
	if self.holder:
		var carryPoint = self.holder.get_node_or_null("flagCarryPoint")
		if carryPoint:
			self.global_transform = carryPoint.global_transform


func set_team(team):
	self._team = team
	var new_m = StandardMaterial3D.new()
	new_m.uv1_triplanar = true
	match team:
		Team.GREEN:
			new_m.albedo_texture = load("res://addons/kenney_prototype_textures/green/texture_08.png")
			$Area3D.collision_mask = 4
		Team.PURPLE:
			new_m.albedo_texture = load("res://addons/kenney_prototype_textures/purple/texture_08.png")
			$Area3D.collision_mask = 2
	$flag.set_surface_override_material(0, new_m)


func set_spawn(pos : Transform3D):
	self._spawn = pos


func _on_area_3d_body_entered(body):
	if not self.holder:
		print("new holder ", body)
		picked.emit(self._team)
		self.holder = body
		self.holder.player_hit.connect(drop_flag)
		$Timer.stop()
		
		# scan for capture zones
		match self._team:
			Team.GREEN:
				$Area3D.collision_mask = 128 # 128 is greenFlag Capture Layer (the zone in purple spawn)
			Team.PURPLE:
				$Area3D.collision_mask = 256 # 265 is purpleFlag Capture Layer (the zone in green spawn)


func drop_flag(_a, _b):
	self.holder = null
	dropped.emit(self._team)
	$Timer.start(30)
	# scan for players
	match self._team:
		Team.GREEN:
			$Area3D.collision_mask = 4 # 4 is purplePlayers
		Team.PURPLE:
			$Area3D.collision_mask = 2 # 2 is greenPlayers


# Respawn the flag when it times out
func _on_timer_timeout():
	self.global_transform = self._spawn
	returned.emit(self._team)
	# scan for players
	match self._team:
		Team.GREEN:
			$Area3D.collision_mask = 4 # 4 is purplePlayers
		Team.PURPLE:
			$Area3D.collision_mask = 2 # 2 is greenPlayers


func _on_area_3d_area_entered(area):
	print(area)
	# stop scanning for collisions
	$Area3D.collision_mask = 0
	captured.emit(self._team)
	self.global_transform.origin = Vector3(0, -10, 0)
	$Timer.start(8)
