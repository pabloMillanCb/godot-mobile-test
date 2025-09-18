extends CharacterBody2D

@onready var player = get_parent().get_node("Player")
var chasing_player = false

func _ready():
	GlobalSignals.player_starts_advancing.connect(func(): 
		$StopFollowingTimer.start()
		chasing_player = true)

func _physics_process(delta):
	var direction = global_position.direction_to(player.global_position).normalized()
	if (chasing_player):
		var SPEED = 800
		velocity = velocity.move_toward(direction * SPEED, SPEED*delta)
		move_and_slide()
		const EPSILON = 2
		print(global_position.distance_to(player.global_position))
		if (global_position.distance_to(player.global_position) <= EPSILON):
			velocity = Vector2.ZERO
			chasing_player = false
	elif ($StopFollowingTimer.time_left == 0):
		global_position = player.global_position

func _on_area_2d_body_entered(body):
	print(body.global_position)
