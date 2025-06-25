extends CharacterBody3D

@export var speed = 4
@export var fall_acceleration = 75

var target_velocity = Vector3.ZERO

func _physics_process(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	var anim_player = $AnimationPlayer # Adjust path as needed

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		var look = Basis.looking_at(direction)
		look = look.rotated(Vector3.UP, PI)
		$Rig.basis = look

		# Play walk animation
		if anim_player.current_animation != "Walking_B":
			anim_player.play("Walking_B")
	else:
		# Play idle animation
		if anim_player.current_animation != "Idle":
			anim_player.play("Idle")

	# Apply velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	if not is_on_floor():
		target_velocity.y = target_velocity.y - fall_acceleration * delta

	velocity = target_velocity
	move_and_slide()
