extends RigidBody3D

var ply_id

@export var GreenMaterial : StandardMaterial3D
@export var PurpleMaterial : StandardMaterial3D

func _ready():
	self.contact_monitor = true
	self.max_contacts_reported = 1


func set_shooter(player_id : int):
	if PlayerData.get_player_team(player_id) == Team.GREEN:
		$Mesh.set_surface_override_material(0, GreenMaterial)
	else:
		$Mesh.set_surface_override_material(0, PurpleMaterial)
	ply_id = player_id


func _physics_process(_delta):
	if position.y <= -10:
		queue_free()


func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(1, ply_id)
	queue_free()
