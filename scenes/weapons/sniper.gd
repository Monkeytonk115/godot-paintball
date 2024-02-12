extends Node3D

# Fire rate of 0.5 rounds per second
const fire_delay = 1.0 / 0.5
const automatic = false

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
	get_node("/root/Main/").shoot_bullet_client.rpc($attachment_muzzle.global_transform, -$attachment_muzzle.global_transform.basis.z * 50)
	_next_fire_time = Time.get_ticks_msec() + (fire_delay * 1000)