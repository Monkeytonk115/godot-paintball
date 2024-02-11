extends Node3D

signal shoot_bullet(origin : Transform3D, velocity : Vector3)

# Fire rate of 15 rounds per second
const fire_delay = 1.0 / 15.0


var _next_fire_time

# Called when the node enters the scene tree for the first time.
func _ready():
	_next_fire_time = Time.get_ticks_msec()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func PrimaryFire():
	print("PrimaryFire")
	if _next_fire_time >= Time.get_ticks_msec():
		# Can't fire right now, need to wait
		pass
	
	# shoot effects
	# shoot bullet
	shoot_bullet.emit($attachment_muzzle.global_transform, -$attachment_muzzle.global_transform.basis.z * 10)
	_next_fire_time = Time.get_ticks_msec() + (fire_delay * 1000)
