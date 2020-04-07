extends Node2D

var tweenNode 
var turnOverTweenNode 
var timerNode

# массив с описанием стадий вращения 
# индексы: 
# 	0 - количество очков для входа в стадию
# 	1 - коэффицент для расчёта скорости вращения (на него нужно будет домножить количество очков)
# 	2 - максимальная скорость вращения стадии
# 	3 - частота пульсаций
# 	4 - длительность импульса пульсаций
# 	5 - шанс переворота поля 
var states = [
	[0, 0, 0, 2, 0.4, 0.0], 
	[5, 0.01, 1, 0.675, 0.2, 0.2], 
	[20, 0.01, 1, 0.675, 0.2, 0.5], 
	[50, 0.01, 1, 0.675, 0.2, 1]]
enum STATE_PARAM {
	MIN_POINTS,
	SPEED_COEFF,
	MAX_SPEED,
	PULSATION_FREQ,
	IMPULSE_DURATION,
	TURN_OVER_CHANCE
}
var curState = 0
var isRotClockwise = true if randi() % 2 == 1 else false # выбираем случайную сторону вращения при запуске


func _ready():
	tweenNode = $Tween
	turnOverTweenNode = $TurnOverTween
	timerNode = $Tween/Timer
	
	timerNode.start(states[curState][STATE_PARAM.PULSATION_FREQ])
	
	position = Global.displaySize / 2

func _process(delta):
	# вращение
	if not turnOverTweenNode.is_active():
		rotate(deg2rad(states[curState][STATE_PARAM.SPEED_COEFF] * Global.points * (1 if isRotClockwise else -1))) 


func pulse_the_scale():
	var impulseDuration = states[curState][STATE_PARAM.IMPULSE_DURATION]
	tweenNode.interpolate_property(self, "scale", scale * 1.05, scale, impulseDuration, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	tweenNode.start()

func point_catched():
	pulse_the_scale()
	
	# переворот
	var turnOverChance = states[curState][STATE_PARAM.TURN_OVER_CHANCE]
	if turnOverChance > 0 and (turnOverChance == 1 or randi() % int(1/turnOverChance) == 0):
		turn_over()
	
	# изменение позиции
	#change_pos()
	
	# смена угла вращения
	isRotClockwise = false if randi() % 2 == 1 else true
	
	# смена стадии
	if curState < states.size() - 1 and Global.points >= states[curState + 1][STATE_PARAM.MIN_POINTS]:
		curState += 1
		timerNode.wait_time = states[curState][STATE_PARAM.PULSATION_FREQ]


# быстрый переворот поля
func turn_over():
	var turnAng = randi() % 360 - 180
	var impulseDuration = states[curState][STATE_PARAM.IMPULSE_DURATION] * 3
	turnOverTweenNode.interpolate_property(self, "rotation_degrees", rotation_degrees, rotation_degrees + turnAng, impulseDuration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	turnOverTweenNode.start()


# смена позиции игрового поля
func change_pos():
	var newPos = Global.displaySize / 2 + Vector2(randi() % 100 - 50, randi() % 200 - 100)
	var duration = 4
	turnOverTweenNode.interpolate_property(self, "position", position, newPos, duration, Tween.TRANS_LINEAR)
	turnOverTweenNode.start()
