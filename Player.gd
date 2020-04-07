extends Area2D

# список точек, к которым может двигаться игрок
var moveTargets = [Vector2(0,0), Vector2(100,100)]

# номер точки, к которой движется игрок
var moveTargetTo = 0
# номер точки, от которой движется игрок
var moveTargetFrom = 1

var moveSpeed = 100


func _process(delta):
	var moveVec = moveTargets[moveTargetTo] - position
	moveVec = moveVec.normalized() * moveSpeed * delta
	
	position += moveVec


# разворачивает направление движения
func revert_move_dir():
	var oldMoveTargetTo = moveTargetTo
	
	moveTargetTo = moveTargetFrom
	moveTargetFrom = oldMoveTargetTo


# обработка столкновений
func _on_Player_area_entered(area):
	if area.is_in_group("wall"):
		revert_move_dir()
	elif area.is_in_group("point"):
		if not area.isCatched:
			area.set_catched(true)
	elif area.is_in_group("enemy"):
		Global.points = 0
		get_tree().reload_current_scene()
