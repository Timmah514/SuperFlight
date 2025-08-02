extends CharacterBody3D


var speed = 2.0
var maxSpeed = 15
var maxFlySpeed = 75
var sensitivity = 0.3 
var jumpHeight = 25
var gravity = 0.4
var friction = 1
var drag = 0.25
var dashStrength = 80
var maxEnergy = 125
@onready var energy = maxEnergy

var prevMousePos = Vector2.ZERO
@onready var camera = $Camera3D

func _ready():
	globals.player = self
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	#friction
	apply_friction(velocity, delta)
	
	#ground movement
	var prevVel = velocity
	if is_on_floor():
		if energy < maxEnergy:
			energy += 0.6 * delta * 60
		
	velocity += (get_global_transform().basis.z * (Input.get_action_strength("Move Forward") - Input.get_action_strength("Move Backward")) + get_global_transform().basis.x * (Input.get_action_strength("Move Left") - Input.get_action_strength("Move Right"))).normalized() * speed
	if sqrt(velocity.x * velocity.x + velocity.z * velocity.z) > maxSpeed:
		velocity = prevVel
		#jump
	if Input.is_action_just_pressed("Jump"):
		if is_on_floor():
			velocity.y = jumpHeight
		elif energy > 0:
			velocity.y = jumpHeight
			energy -= 10
	
	#air movement
	if Input.is_action_pressed("Ground Pound"):
		velocity.y -= 1.5 * delta * 60
		if energy < maxEnergy:
			energy += 0.85 * delta * 60
	elif Input.is_action_pressed("Fly") && energy > 0:
		if  velocity.length() < maxFlySpeed :
			velocity += camera.get_global_transform().basis.z * -speed * delta * 60
			energy -= 0.25 * delta * 60
		else:
			energy -= 0.1 * delta * 60
	elif !(Input.is_action_pressed("Fly") && energy > 0):
		velocity.y -= gravity * delta * 60
	
	#dash
	if Input.is_action_just_pressed("Dash") && energy > 0:
		energy -= 35
		if Input.is_action_pressed("Fly"):
			velocity += camera.get_global_transform().basis.z * -dashStrength
		else:
			if (get_global_transform().basis.z * (Input.get_action_strength("Move Forward") - Input.get_action_strength("Move Backward")) + get_global_transform().basis.x * (Input.get_action_strength("Move Left") - Input.get_action_strength("Move Right"))).normalized() != Vector3.ZERO:
				velocity += (get_global_transform().basis.z * (Input.get_action_strength("Move Forward") - Input.get_action_strength("Move Backward")) + get_global_transform().basis.x * (Input.get_action_strength("Move Left") - Input.get_action_strength("Move Right"))).normalized() * dashStrength
			else:
				velocity += velocity.normalized() * dashStrength
	
	#cam fov
	#camera.fov = 80 + (5.0 * ( velocity.length() / maxFlySpeed))
	
	move_and_slide()

func _input(event):    
	#mouse look     
	if (event is InputEventMouseMotion) && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera.rotate_x(deg_to_rad(event.relative.y * sensitivity))
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -75, 75)
		camera.rotation_degrees.y = 180
		camera.rotation_degrees.z = 0
		
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))

func knockback(force):
	velocity += force

func apply_friction(prevVel, delta):
	if is_on_floor():
		velocity -= Vector3(velocity.x, 0, velocity.z).normalized() * friction * delta * 60
	else:
		velocity -= velocity.normalized() * drag * delta * 60
	
	if prevVel.x > 0 && velocity.x < 0:
		velocity.x = 0
	elif prevVel.x < 0 && velocity.x > 0:
		velocity.x = 0
	if prevVel.z > 0 && velocity.z < 0:
		velocity.z = 0
	elif prevVel.z < 0 && velocity.z > 0:
		velocity.z = 0 
