extends RigidBody3D


func _ready():
	self.contact_monitor = true
	self.max_contacts_reported = 1


func _process(delta):
	pass


func _on_body_entered(body):
	print("hit")
	queue_free()
