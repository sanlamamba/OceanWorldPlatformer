extends CharacterBody2D

# Constants for movement and jumping.
const SPEED = 120.0
const JUMP_VELOCITY = -250.0

# Variables to track state.
var just_double_jumped: bool = false
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# Node references.
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()
	handle_movement(delta)
	update_animation()

func apply_gravity(delta: float) -> void:
	# Apply gravity when not grounded.
	if not is_on_floor():
		velocity.y += gravity * delta

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		attempt_jump()

func attempt_jump() -> void:
	if is_on_floor() or not just_double_jumped:
		velocity.y = JUMP_VELOCITY
		animated_sprite.play("jump" if is_on_floor() else "double_jump")
		just_double_jumped = not is_on_floor()

func handle_movement(delta: float) -> void:
	var direction: float = Input.get_axis("left", "right")
	velocity.x = direction * SPEED
	animated_sprite.flip_h = direction < 0
	if direction == 0:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta)
	move_and_slide()

func update_animation() -> void:
	if is_on_floor():
		just_double_jumped = false
		animated_sprite.play("idle" if velocity.x == 0 else "run")

