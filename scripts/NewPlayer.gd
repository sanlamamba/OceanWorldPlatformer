extends CharacterBody2D

@export var move_speed = 120.0
@export var jump_height : float
@export var jump_time_to_peak : float
@export var jump_time_to_decent : float


# Variables to track states
var just_double_jumped: bool = false
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")


# Node references.
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_decent * jump_time_to_decent)) * -1.0

@onready var left_outer = $left_outer
@onready var left_inner = $left_inner
@onready var right_inner = $right_inner
@onready var right_outer = $right_outer
@onready var player = $"."



#starting position of player, initiate timer
func _ready():
	player.global_position.x = 0
	player.global_position.y = -17
	

func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_jump()
	handle_movement(delta)
	update_animation()
	force_player_move()

#returns either jump_gravity or fall_gravity depending on wether player moves up or down
func get_gravity() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

# Apply gravity when not grounded.
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity() * delta

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		attempt_jump()

func attempt_jump() -> void:
	if is_on_floor() or not just_double_jumped:
		velocity.y = jump_velocity
		animated_sprite.play("jump" if is_on_floor() else "double_jump")
		just_double_jumped = not is_on_floor()

func handle_movement(delta: float) -> void:
	var direction: float = Input.get_axis("left", "right")
	velocity.x = direction * move_speed
	animated_sprite.flip_h = direction < 0
	if direction == 0:
		velocity.x = move_toward(velocity.x, 0, move_speed * delta)
	move_and_slide()

func update_animation() -> void:
	if is_on_floor():
		just_double_jumped = false
		animated_sprite.play("idle" if velocity.x == 0 else "run")

#checks if player is on one_way collison object: if yes, lets player go down
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("down") and is_on_floor():
		position.y += 1



func force_player_move() -> void:
	if left_outer.is_colliding() and !left_inner.is_colliding() and !right_inner.is_colliding() and !right_outer.is_colliding():
		player.global_position.x += 3
		print("moved right")
	elif right_outer.is_colliding() and !right_inner.is_colliding() and !left_inner.is_colliding() and !left_outer.is_colliding():
		player.global_position.x -= 3
		print("moved left")



