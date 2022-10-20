extends KinematicBody2D

signal died

enum State { NORMAL, DASHING }

var gravity = 1000
var velocity = Vector2.ZERO
var maxHorizontalSpeed = 140
var maxDashSpeed = 500
var minDashSpeed = 200
var horizontalAcceleration = 2000
var jumpSpeed = 360
var jumpTerminationMultiplier = 4
var hasDoubleJump = false
var currentState = State.NORMAL
var isStateNew = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$HazardArea.connect("area_entered", self, "on_hazard_area_entered")

func _process(delta):
	match currentState:
		State.NORMAL:
			process_normal(delta)
		State.DASHING:
			process_dash(delta)
	isStateNew = false
	
func change_state(newState):
	currentState = newState
	isStateNew = true
	
func process_normal(delta):
	#player movement
	var moveVector = get_movement_vector()
	velocity.x += moveVector.x * horizontalAcceleration * delta
	if(moveVector.x == 0):
		velocity.x = lerp(0,velocity.x,pow(2,-50 * delta))
	
	#player can only reach a maximum speed
	velocity.x = clamp(velocity.x,-maxHorizontalSpeed,maxHorizontalSpeed)
	
	#player jump
	if(moveVector.y < 0 && (is_on_floor() || !$CoyoteTimer.is_stopped() || hasDoubleJump)):
		velocity.y = moveVector.y * jumpSpeed
		if(!is_on_floor() && $CoyoteTimer.is_stopped()):
			hasDoubleJump = false
		$CoyoteTimer.stop()
		
	if(velocity.y < 0 && !Input.is_action_pressed("jump")):
		velocity.y += gravity * jumpTerminationMultiplier * delta
	else:
		velocity.y += gravity * delta
		
	var wasOnFloor = is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if(wasOnFloor && !is_on_floor()):
		$CoyoteTimer.start()
	
	if(is_on_floor()):
		hasDoubleJump = true
		
	if( Input.is_action_just_pressed("dash")):
		call_deferred("change_state",State.DASHING)
	
	update_animation()
	
func process_dash(delta):
	if(isStateNew):
		$AnimatedSprite.play("jump")
		var moveVector = get_movement_vector()
		var velocityMod = 1
		if(moveVector.x != 0):
			velocityMod = sign(moveVector.x)
		else:
			velocityMod = 1 if $AnimatedSprite.flip_h else -1
			
		velocity = Vector2(maxDashSpeed * velocityMod,0)
	velocity = move_and_slide(velocity,Vector2.UP)
	velocity.x = lerp(0,velocity.x,pow(2,-8 * delta))
	
	if(abs(velocity.x) < minDashSpeed):
		call_deferred("change_state",State.NORMAL)

func get_movement_vector():
	var moveVector = Vector2.ZERO
	moveVector.x = Input.get_action_raw_strength("move_right") - Input.get_action_raw_strength("move_left")
	moveVector.y = -1 if Input.is_action_just_pressed("jump") else 0
	return moveVector

func update_animation():
	var moveVec = get_movement_vector()
	
	if(!is_on_floor()):
		$AnimatedSprite.play("jump")
	elif(moveVec.x != 0):
		$AnimatedSprite.play("run")
	else:
		$AnimatedSprite.play("idle")
		
	if(moveVec.x != 0):
		$AnimatedSprite.flip_h = true if moveVec.x > 0 else false

func on_hazard_area_entered(area2d):
	emit_signal("died")
