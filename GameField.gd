extends Node2D

onready var pulsationTweenNode = $PulsationTween
onready var turnOverTweenNode = $TurnOverTween

enum ROT_MODES {
	NO_ROT,
	TWEEN_TO_POINT,
	CONTINUOUS
}
enum STATE_PARAM {
	MIN_POINTS,
	ROT_MODE,
	TURN_OVER_CHANCE,
	MIN_SPEED,
	MAX_SPEED,
	POINTS_TO_MAX_SPEED
}
# массив с описанием стадий вращения 
# индексы: 
# 	0 - количество очков для входа в стадию
# 	1 - метод вращения
# 	2 - шанс переворота поля
# 	3 - начальная скорость вращения
# 	4 - максимальная скорость вращения
# 	5 - количество поинтов до максимальной скорости вращения (предполагается, что скорость вращения поля нарастает линейно)
var states = [
	[0, ROT_MODES.NO_ROT], 
	[5, ROT_MODES.TWEEN_TO_POINT], 
	[8, ROT_MODES.TWEEN_TO_POINT], 
	[11, ROT_MODES.TWEEN_TO_POINT], 
	[14, ROT_MODES.TWEEN_TO_POINT], 
	[17, ROT_MODES.TWEEN_TO_POINT], 
	[20, ROT_MODES.TWEEN_TO_POINT], 
	[23, ROT_MODES.TWEEN_TO_POINT], 
	[26, ROT_MODES.CONTINUOUS, 0, 1, 10, 10], 
	[36, ROT_MODES.CONTINUOUS, 0.2, 10, 50, 20], 
	[56, ROT_MODES.CONTINUOUS, 0.5, 50, 100, 20]]
var curState = 0
var isRotClockwise = true if randi() % 2 == 0 else false

var impulseDuration = 0.2
var turnOverDuration = 0.6
var tweenToPointRotModeDegrees = 45
var tweenToPointRotModeDuration = 10


func _ready():
	# позиционирование в центр дисплея
	position = Global.displaySize / 2


func _process(delta):
	# вращение 
	if states[curState][STATE_PARAM.ROT_MODE] == ROT_MODES.CONTINUOUS:
		if not turnOverTweenNode.is_active(): # если переворот не происходит
			var minPoints = states[curState][STATE_PARAM.MIN_POINTS]
			var minSpeed = states[curState][STATE_PARAM.MIN_SPEED]
			var maxSpeed = states[curState][STATE_PARAM.MAX_SPEED]
			var pointsToMax = states[curState][STATE_PARAM.POINTS_TO_MAX_SPEED]
			var deltaSpeedForPoint = float(maxSpeed - minSpeed) / pointsToMax
			var deltaSpeed = maxSpeed if Global.points >= minPoints + pointsToMax else float(Global.points - minPoints) / float(pointsToMax) *  deltaSpeedForPoint
			rotate(deg2rad((minSpeed + deltaSpeed) * (1 if isRotClockwise else -1)) * delta) 


# анимация пульсации
func pulse_the_scale():
	pulsationTweenNode.interpolate_property(self, "scale", scale * 1.05, scale, 
			impulseDuration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	pulsationTweenNode.start()


# обработка внешнего сигнала (поинт пойман)
func point_catched():
	pulse_the_scale()
	
	# переворот
	if states[curState][STATE_PARAM.ROT_MODE] == ROT_MODES.CONTINUOUS:
		var turnOverChance = states[curState][STATE_PARAM.TURN_OVER_CHANCE]
		if turnOverChance > 0 and (turnOverChance == 1 or randi() % int(1/turnOverChance) == 0):
			turn_over()
		
		# смена угла вращения
		isRotClockwise = false if randi() % 2 == 1 else true
	
	# изменение позиции
	#change_pos()
	
	# смена стадии
	if curState < states.size() - 1 and Global.points >= states[curState + 1][STATE_PARAM.MIN_POINTS]:
		curState += 1
		if states[curState][STATE_PARAM.ROT_MODE] == ROT_MODES.TWEEN_TO_POINT:
			turn_over(tweenToPointRotModeDegrees, tweenToPointRotModeDuration)


# переворот поля
func turn_over(_turnAng = randi() % 360 - 180, _duration = turnOverDuration):
	turnOverTweenNode.interpolate_property(self, "rotation_degrees", rotation_degrees, rotation_degrees + _turnAng, 
			_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	turnOverTweenNode.start()


# изменение позиции игрового поля
#func change_pos():
#	var newPos = Global.displaySize / 2 + Vector2(randi() % 100 - 50, randi() % 200 - 100)
#	var duration = 4
#	turnOverTweenNode.interpolate_property(self, "position", position, newPos, duration, Tween.TRANS_LINEAR)
#	turnOverTweenNode.start()
