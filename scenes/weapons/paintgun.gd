extends Node3D

const bullet = preload("res://scenes/weapons/paintball.tscn")

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
	var new_bullet = bullet.instantiate()
	new_bullet.global_transform = $attachment_muzzle.global_transform
	new_bullet.linear_velocity = -$attachment_muzzle.global_transform.basis.z * 20
	get_node("/root/Main/bullets").add_child(new_bullet)
	_next_fire_time = Time.get_ticks_msec() + (fire_delay * 1000)
