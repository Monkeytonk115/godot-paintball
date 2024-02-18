extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var equipped_weapon

var loadout = ["res://scenes/weapons/paintgun.tscn"]
var _respawn_point : Vector3

func _enter_tree():
	# Can only change multiplayer authority from inside _enter_tree()
	set_multiplayer_authority(str(name).to_int())


func _ready():
	if not is_multiplayer_authority(): return

	# Hide our own body in multiplayer
	#$humanoid.hide()

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Camera3D.current = true
	
	equip.rpc(loadout[0])


func _process(_delta):
	if not is_multiplayer_authority(): return
	$Camera3D.transform = $humanoid/Eye.transform


func _unhandled_input(event):
	if not is_multiplayer_authority(): return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		$humanoid/Eye.rotate_x(-event.relative.y * 0.005)
		$humanoid/Eye.rotation.x = clamp($humanoid/Eye.rotation.x, -PI/2, PI/2)
		
		equipped_weapon.rotation.x = $humanoid/Eye.rotation.x


func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	if _respawn_point != Vector3.INF:
		global_transform.origin = _respawn_point
		_respawn_point = Vector3.INF
	
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


@rpc("authority", "call_local")
func equip(wep : String):
	print("equipping ", wep)
	equipped_weapon = load(wep).instantiate()
	$humanoid/hand_right.add_child(equipped_weapon)
	equipped_weapon.transform = equipped_weapon.find_child("attachment_0").transform.inverse()
