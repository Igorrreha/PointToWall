extends Area2D

onready var lightModeChangeSoundNode = $LightModeChangeSound
onready var lightNodeTimerNode = $LightModeTimer
onready var lightNode = $Light2D

# список точек, к которым может двигаться игрок
var moveTargets = [Vector2(0,0), Vector2(100,100)]
# номер точки, к которой движется игрок
var moveTargetTo = 0
# номер точки, от которой движется игрок
var moveTargetFrom = 1

export var radius = 12
export var moveSpeed = 100
export var rotSpeed = 180


func _process(delta):
	var moveVec = moveTargets[moveTargetTo] - position
	moveVec = moveVec.normalized() * moveSpeed * delta
	
	position += moveVec
	rotate(deg2rad(rotSpeed * delta))


# разворачивает направление движения
func revert_move_dir():
	var oldMoveTargetTo = moveTargetTo
	
	moveTargetTo = moveTargetFrom
	moveTargetFrom = oldMoveTargetTo
	
	rotSpeed = -rotSpeed


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


# включение / выключение света 
# вызывается по сигналу GameField - lightModeChanged
func set_light_mode(_setImmediately = false):
	lightNodeTimerNode.start(Global.lightModeChangeDuration)
	yield(lightNodeTimerNode, "timeout")
	lightNode.visible = not Global.isLightOn
	if not _setImmediately:
		lightModeChangeSoundNode.play()
