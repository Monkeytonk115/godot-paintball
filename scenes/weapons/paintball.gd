extends RigidBody3D


func _ready():
	pass


func _process(delta):
	pass


func _on_body_entered(body):
	print("hit")
	queue_free()
