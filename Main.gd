extends Control

var FlyingObstacleTscn = preload("res://enemies/FlyingObstacle.tscn")

onready var playerNode = $GameField/Player
onready var pointCounterNode = $UI/VBoxContainer/PointsCounter
onready var consoleNode = $UI/VBoxContainer/Console
onready var gameFieldNode = $GameField
onready var enemiesContainerNode = $GameField/Enemies
onready var wallsContainer = $GameField/Walls

export var wallToCenterDistance = Vector2(-180, 0)


func _ready():
	pointCounterNode.text = "Points: " + str(Global.points)
	
	# заполнение массива целевых точек
	playerNode.moveTargets = []
	
	var wallsArr = wallsContainer.get_children()
	for i in range(wallsArr.size()):
		var wall = wallsArr[i]
		playerNode.moveTargets.push_back(wall.position + wall.pointNode.get_parent().position.rotated(wall.rotation))
		if wall.pointNode.isCatched:
			playerNode.moveTargetFrom = i
		else: 
			playerNode.moveTargetTo = i
		
		# позиционирование стен
		wall.position = wallToCenterDistance.rotated(wall.rotation)
		
		# присоединение сигналов
		wall.pointNode.connect("point_catched", self, "point_catched")
		gameFieldNode.connect("light_mode_changed", wall, "set_light_mode")
	
	gameFieldNode.connect("light_mode_changed", playerNode, "set_light_mode")


func _process(delta):
	
	# обновить значения массива целевых точек
	var wallsArr = wallsContainer.get_children()
	for i in range(wallsArr.size()):
		var wall = wallsArr[i]
		playerNode.moveTargets[i] = wall.position + wall.pointNode.get_parent().position.rotated(wall.rotation)
		
		# приближение целевой точки к стене при выключенном поинте
		if wall.pointNode.isCatched:
			playerNode.moveTargets[i].x -= wall.pointNode.get_parent().position.rotated(wall.rotation).x
	
	consoleNode.text = str(Global.displaySize)


# соприкосновение с точкой 
func point_catched():
	
	# активация точек (пойманная точка деактивируется в другом скрипте)
	var wallsArr = wallsContainer.get_children()
	for wall in wallsArr:
		wall.pointNode.set_catched(false)
	
	# запись и вывод количества очков на экран
	Global.points += 1
	pointCounterNode.text = "Points: " + str(Global.points)
	
	# передача потока в скрипт игрового поля
	gameFieldNode.point_catched()


# заспавнить противников
func spawn_enemies():
	var enemyNode = FlyingObstacleTscn.instance()
	enemyNode.position.x += randi() % 160 - 80
	enemyNode.rotation_degrees = randi() % 60 - 30
	
	if enemyNode.is_in_group("light_occluder"):
		if not Global.isLightOn:
			enemyNode.modulate.a = 0
	gameFieldNode.connect("light_mode_changed", enemyNode, "set_light_mode")
	
	enemiesContainerNode.add_child(enemyNode)


func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		for wall in wallsContainer.get_children():
			# блокировка переворота игрока, если тот слишком близко к стене
			var distanceOffset = 1 # дополнительный оффсет
			var wallXToCenter = wall.position.rotated(-wall.rotation).x
			var playerXToCenter = playerNode.position.rotated(-wall.rotation - PI).x
			if abs(wallXToCenter - playerXToCenter) < wall.width/2 + playerNode.radius + distanceOffset:
				return
		playerNode.revert_move_dir()
