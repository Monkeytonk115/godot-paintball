extends Node3D

# Fire rate of 3 rounds per second
const fire_delay = 1.0 / 4
const automatic = false

var _next_fire_time
var ply_id

# Called when the node enters the scene tree for the first time.
func _ready():
	_next_fire_time = Time.get_ticks_msec()


func PrimaryFire(hitPoint):
	#print("PrimaryFire")
	if _next_fire_time >= Time.get_ticks_msec():
		# Can't fire right now, need to wait
		return
	$attachment_muzzle.look_at(hitPoint)
	#$attachment_muzzle.look_at($z_intercept.global_position)
	get_node("/root/Main/").shoot_bullet_client.rpc($attachment_muzzle.global_transform, -$attachment_muzzle.global_transform.basis.z * 35, ply_id)
	fireSound.rpc()
	_next_fire_time = Time.get_ticks_msec() + (fire_delay * 1000)
	
func SecondaryFire(secAction):
	if secAction:
		position = Vector3(-0.8,0.4,0)
	if !secAction:
		position = Vector3(0.026751, 0.322912, -0.093872)
	
	
func animation(_firing):
	pass

@rpc("any_peer", "call_local")
func fireSound():
	$AudioStreamPlayer3D.pitch_scale = randf_range(0.95, 1.05)
	$AudioStreamPlayer3D.volume_db = randf_range(0.95, 1.05)
	$AudioStreamPlayer3D.play()
