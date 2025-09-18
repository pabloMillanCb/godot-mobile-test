extends StaticBody2D

func _process(delta):
	const MOVEMENT_SPEED = 2300
	position += Vector2.UP.rotated(rotation)*delta*MOVEMENT_SPEED
	
	#scale = Vector2(max(scale.x - 5*delta, 0), max(scale.y - 5*delta, 0))


func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()
