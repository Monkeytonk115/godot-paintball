extends RigidBody3D

signal nuked


func _ready():
	self.contact_monitor = true
	self.max_contacts_reported = 1
	$Camera3D.make_current()
	angular_velocity = Vector3(0, 0.1, 0)


func _on_body_entered(body):
	nuked.emit()
	$AudioStreamPlayer3D.play()
	self.contact_monitor = false
