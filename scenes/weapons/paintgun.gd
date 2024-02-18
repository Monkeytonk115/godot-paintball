extends Node3D

# Fire rate of 3 rounds per second
const fire_delay = 1.0 / 3.0
const automatic = false

var _next_fire_time
var ply_id

# Called when the node enters the scene tree for the first time.
func _ready():
	_next_fire_time = Time.get_ticks_msec()


func PrimaryFire():
	#print("PrimaryFire")
	if _next_fire_time >= Time.get_ticks_msec():
		# Can't fire right now, need to wait
		return
	
	# shoot effects
	# shoot bullet
	get_node("/root/Main/").shoot_bullet_client.rpc($attachment_muzzle.global_transform, -$attachment_muzzle.global_transform.basis.z * 35, ply_id)
	_next_fire_time = Time.get_ticks_msec() + (fire_delay * 1000)
	
func animation(_firing):
	pass
