extends Node3D

# Fire rate of 4 seconds per round
const fire_delay = 4
const automatic = false

var _next_fire_time
var reloaded

var ply_id

# Called when the node enters the scene tree for the first time.
func _ready():
	_next_fire_time = Time.get_ticks_msec()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	reloaded = true
	pass


func PrimaryFire():
	#print("PrimaryFire")
	#print(Time.get_ticks_msec())
	if !reloaded:
		# Can't fire right now, need to wait
		return
	
	# shoot effects
	# shoot bullet
	
	_next_fire_time = Time.get_ticks_msec() + (fire_delay * 1000)
	
func animation(firing):
	if firing == 1:
		if reloaded:
			if !$AnimationPlayer.is_playing():
				$AnimationPlayer.play("reload")
	if firing == 0:
		return
		
func animReload():
	reloaded = true
	
func animFire():
	get_node("/root/Main/").shoot_bullet_client.rpc($attachment_muzzle.global_transform, -$attachment_muzzle.global_transform.basis.z * 75, ply_id)
	fireSound.rpc()

@rpc("any_peer", "call_local")
func fireSound():
	$AudioStreamPlayer3D.pitch_scale = randf_range(1, 1.2)
	$AudioStreamPlayer3D.play()
