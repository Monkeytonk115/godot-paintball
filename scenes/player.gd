extends CharacterBody3D

signal player_hit(this : Node, attacker_id : int)


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var equipped_weapon

var player_health = 100

func _enter_tree():
	# Can only change multiplayer authority from inside _enter_tree()
	set_multiplayer_authority(str(name).to_int())


func _ready():
	if not is_multiplayer_authority(): return

	# Hide our own body in multiplayer
	#$humanoid.hide()

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Camera3D.current = true


func _process(_delta):
	if not is_multiplayer_authority(): return
	$Camera3D.transform = $humanoid/Eye.transform


func _unhandled_input(event):
	if not is_multiplayer_authority(): return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		$humanoid/Eye.rotate_x(-event.relative.y * 0.005)
		$humanoid/Eye.rotation.x = clamp($humanoid/Eye.rotation.x, -PI/2, PI/2)
		
		if equipped_weapon:
			equipped_weapon.rotation.x = $humanoid/Eye.rotation.x


func _physics_process(delta):
	# Failsafe if the player goes further than 100m from the origin
	if position.length_squared() > 100_000:
		print("too far from origin")
		take_damage(999, -1)

	if not is_multiplayer_authority(): return

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	if equipped_weapon:
		if equipped_weapon.automatic:
			if Input.is_action_pressed("primary_fire"):
				equipped_weapon.PrimaryFire()
				equipped_weapon.animation(1)
		else:
			if Input.is_action_just_pressed("primary_fire"):
				equipped_weapon.PrimaryFire()
				equipped_weapon.animation(1)
		if !Input.is_action_pressed("primary_fire"):
			equipped_weapon.animation(0)


@rpc("any_peer", "call_local")
func equip(wep : String):
	if equipped_weapon:
		equipped_weapon.queue_free()
	print("equipping ", wep)
	equipped_weapon = load(wep).instantiate()
	$humanoid/hand_right.add_child(equipped_weapon)
	equipped_weapon.transform = equipped_weapon.find_child("attachment_0").transform.inverse()
	equipped_weapon.ply_id = str(name).to_int()


@rpc("any_peer", "call_local")
func respawn(respawn_point):
	global_transform.origin = respawn_point
	velocity = Vector3.ZERO


func take_damage(_damage : int, attacker_id : int):
	player_hit.emit(self, attacker_id)
