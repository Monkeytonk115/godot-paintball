extends Node3D

# Fire rate of 20 rounds per second
const fire_delay = 1.0 / 20.0
const automatic = true


var _next_fire_time
var firingSpeed = 1.0

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
	#get_node("/root/Main/").shoot_bullet_client.rpc($attachment_muzzle.global_transform, -$attachment_muzzle.global_transform.basis.z * 15)
	_next_fire_time = Time.get_ticks_msec() + (fire_delay * 1000)
	
func animation(firing):
	if firing == 1:
		if !$AnimationPlayer.is_playing():
			$AnimationPlayer.play("fire", -0.5, firingSpeed)
			if firingSpeed < 5:
				firingSpeed = firingSpeed + 0.1
				#print(firingSpeed)
	if firing == 0:
		if !$AnimationPlayer.is_playing():
			$AnimationPlayer.stop()
			firingSpeed = 1.0

# for minigun, firing is moved to being called from the animation instead, so that firing is timed to the animation speed
func animFunction():
	var aimcone:Transform3D = $attachment_muzzle.global_transform
	aimcone = aimcone.rotated(aimcone.basis.y, randf_range(-0.05, 0.05))
	aimcone = aimcone.rotated(aimcone.basis.x, randf_range(-0.05, 0.05))
	get_node("/root/Main/").shoot_bullet_client.rpc($attachment_muzzle.global_transform, -aimcone.basis.z * 20, ply_id)
	fireSound.rpc()

@rpc("any_peer", "call_local")
func fireSound():
	$AudioStreamPlayer3D.pitch_scale = firingSpeed / randf_range(12, 12.5)
	$AudioStreamPlayer3D.max_db = randf_range(-3, -6)
	$AudioStreamPlayer3D.play()
