extends CharacterBody2D

@onready var player = get_node("/root/Main/Player")

var health = 3
var knockback = false 

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position)
	
	if (knockback):
		direction = direction * -5
		shake()
	
	const SPEED = 100
	const ACCELERATION = 1100
	velocity = velocity.move_toward(direction * SPEED, ACCELERATION * delta)
	move_and_slide()

func take_damage():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("hit")
	knockback = true
	$KnockbackTimer.start()
	health -= 1

	if (health == 0):
		$DeathParticles.restart()
		$Die.play()
		GlobalSignals.enemy_dead.emit()
		$Sprite2D.visible = false

func shake():
	var rng = RandomNumberGenerator.new().randf_range(-6, 6)
	$Sprite2D.offset = Vector2(rng, rng)

func _on_hurtbox_body_entered(body):
	take_damage()
	body.queue_free()


func _on_hitbox_body_entered(body):
	if (body.has_method('kill_player') and health > 0):
		body.kill_player()


func _on_knockback_timer_timeout():
	knockback = false
	$Sprite2D.offset = Vector2(0, 0)


func _on_cpu_particles_2d_finished() -> void:
	queue_free()
