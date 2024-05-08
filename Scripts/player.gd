extends Node


var CurrentGridSize = Vector2i(4, 4)

func StartNextLevel():
	if (Player.CurrentGridSize.x > Player.CurrentGridSize.y):
		Player.CurrentGridSize.y = Player.CurrentGridSize.y + 1
	else:
		Player.CurrentGridSize.x = Player.CurrentGridSize.x + 1
		
	get_tree().reload_current_scene()

func StartPrevLevel():
	if (Player.CurrentGridSize.x <= 2 && Player.CurrentGridSize.y <= 2):
		return
	
	if (Player.CurrentGridSize.x > Player.CurrentGridSize.y):
		Player.CurrentGridSize.x = Player.CurrentGridSize.x - 1
	else:
		Player.CurrentGridSize.y = Player.CurrentGridSize.y - 1
		
	get_tree().reload_current_scene()
