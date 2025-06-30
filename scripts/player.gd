extends CharacterBody3D

@export var speed = 5.0
@export var jump_velocity = 8.0
@export var mouse_sensitivity = 0.2 # Adjust for camera look speed

# Get the gravity from the project settings to be consistent across the engine.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera_spring_arm: SpringArm3D = $SpringArm3D
@onready var player_visual_root: Node3D = $Rig # This is your model's root node
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var camera_pitch = 0.0 # Stores vertical rotation of the camera arm

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Hide and capture mouse cursor

	# Optional: Set initial animation if needed
	# if animation_player.has_animation("Idle"):
	#     animation_player.play("Idle")


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		# Horizontal rotation of the player (yaw)
		rotation_degrees.y -= event.relative.x * mouse_sensitivity

		# Vertical rotation of the camera arm (pitch)
		camera_pitch += event.relative.y * mouse_sensitivity
		camera_pitch = clamp(camera_pitch, -60.0, 60.0) # Clamp vertical camera movement
		camera_spring_arm.rotation_degrees.x = camera_pitch

	if event.is_action_pressed("ui_cancel"): # Escape key to release/capture mouse
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float):
	# Apply gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	# Transform input direction from local space to world space based on player's current rotation
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
			# Orient the player's visual mesh towards the movement direction
			var target_look_at = global_transform.origin + direction
			player_visual_root.look_at(target_look_at, Vector3.UP)
			# Reset player_visual_root's X and Z rotation to prevent tilting due to look_at
			player_visual_root.rotation.x = 0
			player_visual_root.rotation.z = 0
		else:
			# Decelerate when no input
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
	else:
		# Air control (reduced movement in air)
		velocity.x = move_toward(velocity.x, direction.x * speed, speed * delta)
		velocity.z = move_toward(velocity.z, direction.z * speed, speed * delta)

	move_and_slide()

	# --- Animation Logic ---
	# This is where you connect character state to animations
	var is_moving_horizontally = Vector2(velocity.x, velocity.z).length() > 0.1

	if is_on_floor():
		if is_moving_horizontally:
			if animation_player.current_animation != "Walking_B": # Or "Walk"
				animation_player.play("Run") # Make sure you have a "Run" or "Walk" animation
		else: # Not moving horizontally
			if animation_player.current_animation != "Idle":
				animation_player.play("Idle") # Make sure you have an "Idle" animation
	else: # In the air
		if velocity.y > 0: # Going up
			if animation_player.current_animation != "Jump_Start": # Or "JumpLoop"
				animation_player.play("JumpStart") # Make sure you have a "JumpStart" or "JumpLoop" animation
		else: # Going down (falling)
			if animation_player.current_animation != "Jump_Idle":
				animation_player.play("Jump_Idle") # Make sure you have a "Fall" animation
