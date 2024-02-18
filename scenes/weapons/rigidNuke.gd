extends RigidBody3D

signal nuked



func _ready():
	self.contact_monitor = true
	self.max_contacts_reported = 1
	$Camera3D.make_current()


func _on_body_entered(body):
	nuked.emit()
	
