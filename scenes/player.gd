extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var equipped_weapon

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


func _physics_process(delta):
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
	
	if Input.is_action_just_pressed("primary_fire"):
		if equipped_weapon:
			equipped_weapon.PrimaryFire()


func equip(wep : PackedScene):
	equipped_weapon = wep.instantiate()
	$humanoid/hand_right.add_child(equipped_weapon)
	equipped_weapon.transform = equipped_weapon.find_child("attachment_0").transform.inverse()
