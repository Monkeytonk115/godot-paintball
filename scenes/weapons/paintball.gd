extends RigidBody3D

var ply_id

func _ready():
	self.contact_monitor = true
	self.max_contacts_reported = 1


func _physics_process(delta):
	if position.y <= -10:
		queue_free()


func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage(1, ply_id)
	queue_free()
