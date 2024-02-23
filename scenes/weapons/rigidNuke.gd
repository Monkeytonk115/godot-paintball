extends RigidBody3D

signal nuked

var nukeCameraDetatch = 70

func _ready():
	self.contact_monitor = true
	self.max_contacts_reported = 1
	$Camera1.make_current()
	angular_velocity = Vector3(0, 0.1, 0)
	
func _process(delta):
	if $Camera1.global_position.y <= nukeCameraDetatch:
		$Camera2.global_position.y = nukeCameraDetatch
		$Camera2.make_current()
	pass


func _on_body_entered(body):
	nuked.emit()
	$AudioStreamPlayer3D.play()
	self.contact_monitor = false
