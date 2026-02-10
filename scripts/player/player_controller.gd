extends CharacterBody3D

# === PENGATURAN ===
@export_group("Movement")
@export var move_speed: float = 5.0
@export var sprint_speed: float = 8.0
@export var jump_force: float = 8.0
@export var gravity: float = 20.0

@export_group("Camera")
@export var mouse_sensitivity: float = 0.003
@export var camera_min_angle: float = -80.0
@export var camera_max_angle: float = 50.0

# === REFERENSI NODE ===
@onready var camera_arm: SpringArm3D = $CameraArm
@onready var camera: Camera3D = $CameraArm/Camera3D
@onready var player_model: Node3D = $PlayerModel

# === VARIABEL ===
var is_sprinting: bool = false

func _ready() -> void:
	# Kunci mouse ke tengah layar
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	# Rotasi kamera dengan mouse
	if event is InputEventMouseMotion:
		# Rotasi horizontal (kiri-kanan) → putar seluruh player
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Rotasi vertikal (atas-bawah) → putar camera arm
		camera_arm.rotate_x(-event.relative.y * mouse_sensitivity)
		camera_arm.rotation.x = clamp(
			camera_arm.rotation.x,
			deg_to_rad(camera_min_angle),
			deg_to_rad(camera_max_angle)
		)
	
	# Tekan ESC untuk lepas mouse (debug)
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta: float) -> void:
	# === GRAVITY ===
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# === JUMP ===
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force
	
	# === MOVEMENT ===
	# Ambil input WASD
	var input_dir := Input.get_vector(
		"move_left", "move_right", # A, D
		"move_forward", "move_back" # W, S
	)
	
	# Hitung arah gerakan berdasarkan rotasi player
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Sprint
	is_sprinting = Input.is_action_pressed("sprint")
	var current_speed = sprint_speed if is_sprinting else move_speed
	
	# Terapkan gerakan
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		
		# Putar model ke arah gerakan
		player_model.look_at(global_position + direction, Vector3.UP)
	else:
		# Perlambatan saat berhenti
		velocity.x = move_toward(velocity.x, 0, current_speed * delta * 10)
		velocity.z = move_toward(velocity.z, 0, current_speed * delta * 10)
	
	# Jalankan physics
	move_and_slide()
