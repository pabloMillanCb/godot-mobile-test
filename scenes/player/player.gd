extends CharacterBody2D

var on_stop_direction = Vector2.UP
var camera_tween: Tween
var scale_tween: Tween
var color_tween: Tween
var engine_tween: Tween

enum Status {ROTATING, ADVANCING, DEAD}
var state = Status.ADVANCING

func _physics_process(delta):
	
	if (Input.is_action_just_released("action") and state != Status.DEAD):
		set_state(Status.ADVANCING)

	if (Input.is_action_just_pressed("action") and state != Status.DEAD):
		set_state(Status.ROTATING)
		
	if (state == Status.ROTATING):
		process_rotate(delta)
	elif (state == Status.ADVANCING):
		process_advance(delta)

func set_state(new_state: Status):
	if (state != Status.DEAD):
		if (new_state == Status.ROTATING):
			camera_zoom_out()
			$ChargeBoostTimer.start()
			$TurnAccelerationTimer.start()
			start_shooting()
			
		elif (new_state == Status.ADVANCING):
			const MAX_SPEED = 700
			on_stop_direction = Vector2.UP.rotated(rotation)
			velocity = on_stop_direction * MAX_SPEED * (($ChargeBoostTimer.wait_time - $ChargeBoostTimer.time_left)/$ChargeBoostTimer.wait_time)
			camera_zoom_in()
			GlobalSignals.player_starts_advancing.emit()
			stop_shooting()
			$Jump.play()
			
		elif (new_state == Status.DEAD):
			$Hurt.play()
			$DeathParticles.restart() 
			await TimeManager.player_dead_impact()
			stop_shooting()
			$Sprite2D.visible = false
			$DeathParticles.restart()
			$Explode.play()
			$Engine.stop()
			GlobalSignals.player_dead.emit()
			
		state = new_state

func process_rotate(delta):
	const ROTATION_SPEED = 2.4
	const BREAK_FORCE = 420
	var rotation_boost = 1 + 4*($TurnAccelerationTimer.time_left/$TurnAccelerationTimer.wait_time)
	rotate(delta*ROTATION_SPEED*rotation_boost)
	var direction = Vector2.UP.rotated(rotation)
	velocity = velocity.move_toward(on_stop_direction, BREAK_FORCE * delta)
	move_and_slide()

func process_advance(delta):
	const MOVEMENT_SPEED = 350
	const DECELERATION = 900
	#velocity = on_stop_direction * MOVEMENT_SPEED
	velocity = velocity.move_toward(on_stop_direction * MOVEMENT_SPEED, DECELERATION * delta)
	move_and_slide()
	#camera_zoom_in(delta)

func shoot():
	var bullet = preload("res://scenes/player/Bullet.tscn").instantiate()
	bullet.rotation = rotation
	bullet.global_position = $ShootingPoint.global_position
	$AnimationPlayer.play("recoil")
	$ShootParticles.restart()
	get_parent().add_child(bullet)
	var random_pitch = RandomNumberGenerator.new().randf_range(0.9, 1.3)
	$Shoot.pitch_scale = random_pitch
	$Shoot.play()
	
func start_shooting():
	#$ShootingTimeTimer.wait_time =  abs($HeatTimer.time_left - $HeatTimer.wait_time)
	#$ShootingTimeTimer.start()
	$ShootFrequenzyTimer.start()
	$HeatTimer.start()
	$Engine.play()

func stop_shooting():
	$ShootFrequenzyTimer.stop()
	$HeatTimer.stop()
	#$Engine.stop()
	#$Engine.pitch_scale = 1.0

func camera_zoom_in():

	if (camera_tween != null):
		camera_tween.kill()
	camera_tween = get_tree().create_tween()
	camera_tween.set_ease(Tween.EASE_OUT)
	camera_tween.set_trans(Tween.TRANS_QUAD)
	camera_tween.tween_property($Camera2D, "zoom", Vector2(0.8, 0.8), 0.2)
	
	if (scale_tween != null):
		scale_tween.kill()
	scale_tween = get_tree().create_tween()
	scale_tween.set_ease(Tween.EASE_OUT)
	scale_tween.set_trans(Tween.TRANS_QUAD)
	scale_tween.tween_property(self, "scale", Vector2(1.0, 1.7), 0.05)
	scale_tween.chain().tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)
	
	if (color_tween != null):
		color_tween.kill()
	color_tween = get_tree().create_tween()
	color_tween.set_ease(Tween.EASE_OUT)
	color_tween.set_trans(Tween.TRANS_LINEAR)
	scale_tween.tween_property($Sprite2D, "modulate", Color("ffffff"), 0.7)
	
	if (engine_tween != null):
		engine_tween.kill()
	engine_tween = get_tree().create_tween()
	engine_tween.set_ease(Tween.EASE_OUT)
	engine_tween.set_trans(Tween.TRANS_LINEAR)
	engine_tween.tween_property($Engine, "pitch_scale", 1.0, 0.4)
	await engine_tween.finished
	$Engine.stop()
	
func camera_zoom_out():

	if (camera_tween != null):
		camera_tween.kill()

	camera_tween = get_tree().create_tween()
	camera_tween.set_ease(Tween.EASE_OUT)
	camera_tween.set_trans(Tween.TRANS_QUAD)
	camera_tween.tween_property($Camera2D, "zoom", Vector2(0.6, 0.6), $ChargeBoostTimer.wait_time/3*2)
	
	if (scale_tween != null):
		scale_tween.kill()
		
	scale_tween = get_tree().create_tween()
	scale_tween.set_ease(Tween.EASE_OUT)
	scale_tween.set_trans(Tween.TRANS_QUAD)
	scale_tween.tween_property(self, "scale", Vector2(1.0, 0.5), $ChargeBoostTimer.wait_time)
	
	if (color_tween != null):
		color_tween.kill()
	color_tween = get_tree().create_tween()
	color_tween.set_ease(Tween.EASE_OUT)
	color_tween.set_trans(Tween.TRANS_LINEAR)
	scale_tween.tween_property($Sprite2D, "modulate", Color("f72302"), $HeatTimer.wait_time)
	
	if (engine_tween != null):
		engine_tween.kill()
	engine_tween = get_tree().create_tween()
	engine_tween.set_ease(Tween.EASE_OUT)
	engine_tween.set_trans(Tween.TRANS_LINEAR)
	engine_tween.tween_property($Engine, "pitch_scale", 2.0, $HeatTimer.wait_time + 2)


func kill_player():
	print("kill player")
	set_state(Status.DEAD)


func _on_death_particles_finished() -> void:
	pass # Replace with function body.
