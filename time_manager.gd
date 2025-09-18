extends Node

func player_dead_impact():
	Engine.time_scale = 0.05
	await get_tree().create_timer(1.0*0.05).timeout
	Engine.time_scale = 1.0
	
func enemy_dead_impact():
	Engine.time_scale = 0
	await get_tree().create_timer(0.1, true, false, true).timeout
	Engine.time_scale = 1
