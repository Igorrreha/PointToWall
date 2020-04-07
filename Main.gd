extends Control

var playerNode
var pointCounterNode
var gameFieldNode

func _ready():
	gameFieldNode = $GameField
	pointCounterNode = $UI/PointsCounter
	pointCounterNode.text = "Points: " + str(Global.points)
	
	playerNode = $GameField/Player
	
	# заполнить массив целевых точек
	playerNode.moveTargets = []
	
	var wallsArr = $GameField/Walls.get_children()
	for i in range(wallsArr.size()):
		var wall = wallsArr[i]
		playerNode.moveTargets.push_back(wall.position + wall.pointNode.get_parent().position.rotated(wall.rotation))
		if wall.pointNode.isCatched:
			playerNode.moveTargetFrom = i
		else: 
			playerNode.moveTargetTo = i
		
		wall.pointNode.connect("point_catched", self, "point_catched")


func _process(delta):
	
	# обновить значения массива целевых точек
	var wallsArr = $GameField/Walls.get_children()
	for i in range(wallsArr.size()):
		var wall = wallsArr[i]
		playerNode.moveTargets[i] = wall.position + wall.pointNode.get_parent().position.rotated(wall.rotation)
		
		# приближение целевой точки к стене при выключенном поинте
		if wall.pointNode.isCatched:
			playerNode.moveTargets[i].x -= wall.pointNode.get_parent().position.rotated(wall.rotation).x


# соприкосновение с точкой 
func point_catched():
	# переворот игрока
	playerNode.revert_move_dir()
	
	# активация точек (пойманная деактивируется в другом скрипте)
	var wallsArr = $GameField/Walls.get_children()
	for wall in wallsArr:
		wall.pointNode.set_catched(false)
	
	# запись и вывод количества очков на экран
	Global.points += 1
	pointCounterNode.text = "Points: " + str(Global.points)
	
	# передача потока в скрипт игрового поля
	gameFieldNode.point_catched()


func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		playerNode.revert_move_dir()
