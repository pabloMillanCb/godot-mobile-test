extends Node2D

func _process(delta):
	if (Input.is_action_just_pressed("restart")):
		var game = preload("res://scenes/main.tscn").instantiate()
		get_parent().add_child(game)
		queue_free()

func spawn_mob():
	var new_mob = preload("res://scenes/enemy/Enemy.tscn").instantiate()
	%PathFollow2D.progress_ratio = randf()
	new_mob.global_position = %PathFollow2D.global_position
	add_child(new_mob)

func _on_spawn_enemy_timeout():
	spawn_mob()
