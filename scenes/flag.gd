extends Node3D


signal captured(team)
var _team

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
			$Area3D.collision_mask = 4
		Team.PURPLE:
			new_m.albedo_texture = load("res://addons/kenney_prototype_textures/purple/texture_08.png")
			$Area3D.collision_mask = 2
	$flag.set_surface_override_material(0, new_m)


func _on_area_3d_body_entered(body):
	if not self.holder:
		print("new holder ", body)
		self.holder = body
		self.holder.player_hit.connect(drop_flag)


func drop_flag(_a, _b):
	self.holder = null
