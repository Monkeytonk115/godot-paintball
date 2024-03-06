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
		self.global_transform = self.holder.get_node("flagCarryPoint").global_transform


func set_team(team):
	self._team = team
	var new_m = StandardMaterial3D.new()
	new_m.uv1_triplanar = true
	match team:
		Team.GREEN:
			new_m.albedo_texture = load("res://addons/kenney_prototype_textures/green/texture_08.png")
			$Area3D.collision_mask = 4 + 256
		Team.PURPLE:
			new_m.albedo_texture = load("res://addons/kenney_prototype_textures/purple/texture_08.png")
			$Area3D.collision_mask = 2 + 128
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


func drop_flag(_a, _b):
	self.holder = null
	dropped.emit(self._team)
	$Timer.start(30)


func _on_timer_timeout():
	self.global_transform = self._spawn
	returned.emit(self._team)


func _on_area_3d_area_entered(area):
	print(area)
	captured.emit(self._team)
	self.global_transform.origin = Vector3(0, -10, 0)
	$Timer.start(8)
