extends CharacterBody2D

@onready var animation_node: AnimatedSprite2D = $Animation

#timers
@onready var coyote_timer: Timer = $"timers/coyote timer"
@onready var dash_timer: Timer = $"timers/dash timer"
@onready var dash_again: Timer = $"timers/dash again"

#celling raycast
@onready var left_1: RayCast2D = $"celling edge detect/left1"
@onready var left_2: RayCast2D = $"celling edge detect/left2"
@onready var right_2: RayCast2D = $"celling edge detect/right2"
@onready var right_1: RayCast2D = $"celling edge detect/right1"

#right left wall raycast
@onready var right_wall: RayCast2D = $"wall dtection/right"
@onready var left_wall: RayCast2D = $"wall dtection/left"

@export var speed :float = 200.0
@export var acceleration :float = 1000.0
@export var resistanc_air :float = 500.0
@export var jump_velocity :float = -300.0
@export var acceleration_storage :float = acceleration

var dash_dir :int = 1

var fall_jump_anim = true
var dash_anim = true
var coyote_jump = true

func _physics_process(_delta: float) -> void :
	var dir := Input.get_axis("ui_left", "ui_right")
	
	dash(dir , _delta)
	#the movement function is on the dash function
	gravity(_delta)
	air_resistance(dir , _delta)
	handel_jump() #jump + coyote jump
	celling_edge_sliding()
	animation(dir)
	
	move_and_slide()

#void functions
func gravity(_delta) -> void: 
	if not is_on_floor():
		velocity += get_gravity() * _delta

func air_resistance(dir , _delta) -> void :
	if dir == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x , 0 , resistanc_air * _delta)

func handel_jump() -> void :
	
	if !coyote_timer.is_stopped() or is_on_floor():
		#jump property 
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = jump_velocity
	
	#coyote jump abillity
	if not is_on_floor():
		if coyote_jump == true :
			coyote_timer.start()
			coyote_jump = false
	else : coyote_jump = true

func movement(dir , _delta) -> void :
	if dir: #acceleration
		velocity.x = move_toward(velocity.x, dir * speed , acceleration * _delta)
	else: #friction
			velocity.x = move_toward(velocity.x, 0, acceleration * _delta)

func dash(dir ,_delta) -> void :
	
	if Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_left")  :
		if !dash_timer.time_left > 0 :
			dash_dir = 0
	else: 
		if animation_node.flip_h == true :
			dash_dir = -1
		elif animation_node.flip_h == false :
			dash_dir = 1
	
	if dash_timer.is_stopped() or !dash_again.is_stopped() :
		movement(dir , _delta)
	else: # dash property
		velocity.x = dash_dir * speed * 3
		velocity.y = 0
	
	#the signal to start the dash
	if Input.is_action_just_pressed("ui_dash") and dash_timer.is_stopped() and dash_again.is_stopped() :
		#detecting the wall to avoid dash into it
		if (on_wall() == 1 and dash_dir != 1) or (on_wall() == -1 and dash_dir != -1) or on_wall() == 0:
			dash_timer.start()
	
	#the end of dash
	if abs(velocity.x) > speed and dash_timer.is_stopped() : 
		acceleration = acceleration_storage * 4
	elif acceleration != acceleration_storage:
		acceleration = acceleration_storage 

func celling_edge_sliding() -> void :
	if velocity.y < 0 : 
		if left_1.is_colliding() and !left_2.is_colliding() and !right_2.is_colliding() and !right_2.is_colliding() :
			position.x += 3
		elif !left_1.is_colliding() and !left_2.is_colliding() and !right_2.is_colliding() and right_1.is_colliding() :
			position.x -= 3

func animation(dir) -> void :
	
	if dash_timer.is_stopped() : #dash priority
		dash_anim = true
		
		#flip h
		if dir == -1 :
			animation_node.flip_h = true
		elif dir == 1 :
			animation_node.flip_h = false
		
		#movement animation
		if Input.is_action_pressed('ui_right') and Input.is_action_pressed('ui_left') and is_on_floor() :
			animation_node.play("idle")
			dash_anim = false
		elif Input.is_action_pressed('rl_move') and is_on_floor() :
				animation_node.play("walk")
		elif is_on_floor() :
				animation_node.play("idle")
		
		#jump and falling animation
		if not is_on_floor() and velocity.y > 0 and fall_jump_anim == true :
			animation_node.play("fall")
			fall_jump_anim = false
		elif not is_on_floor() and velocity.y <= 0 and fall_jump_anim == true :
			animation_node.play("jump")
			fall_jump_anim = false
		else: 
			fall_jump_anim = true
		
	elif dash_anim == true : #dash animation
		animation_node.play("dash")
		dash_anim = false

#functions
func on_wall():
	var wall_dir:int
	
	if right_wall.is_colliding() and !left_wall.is_colliding() :
		wall_dir = 1 #the wall is on the right
	elif !right_wall.is_colliding() and left_wall.is_colliding() :
		wall_dir = -1 #the wall is on the left
	elif right_wall.is_colliding() and left_wall.is_colliding():
		wall_dir = 2	#the wall is on the left and the right
	else : wall_dir = 0 #there no wall
	
	return wall_dir

func _on_dash_timer_timeout() -> void:
	dash_again.start()
