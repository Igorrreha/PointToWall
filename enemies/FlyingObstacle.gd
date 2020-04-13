extends Node2D

export var MoveCurveLinear = preload("res://enemies/path_curves/linear.tres")
var MoveCurveZigzag = preload("res://enemies/path_curves/zigzag.tres")

onready var moveTweenNode = $MoveTween
onready var scaleTweenNode = $ScaleTween
onready var lightModeTweenNode = $LightModeTween
onready var scaleOutTimerNode = $ScaleOutTimer
onready var destroyTimerNode = $DestroyTimer
onready var pathNode = $Path2D
onready var pathFollowNode = $Path2D/PathFollow2D
onready var bodyNode = $Path2D/PathFollow2D/Body

var isMoveBackwards = true if randi() % 2 == 1 else false

var rotSpeed = randi() % 360 - 180

var moveDuration = randi() % 5 + 5
var inOutTweenDuration = 0.5


func _ready():
	
	pathNode.curve = MoveCurveLinear
	
	moveTweenNode.interpolate_property(pathFollowNode, "unit_offset", int(isMoveBackwards), int(not isMoveBackwards), moveDuration, Tween.TRANS_LINEAR)
	moveTweenNode.start()
	
	scaleTweenNode.interpolate_property(bodyNode, "scale", Vector2(0,0), Vector2(1,1), inOutTweenDuration, Tween.TRANS_LINEAR)
	scaleTweenNode.start()
	
	scaleOutTimerNode.start(moveDuration - inOutTweenDuration)
	
	destroyTimerNode.start(moveDuration)


func _process(delta):
	bodyNode.rotate(deg2rad(rotSpeed) * delta)


# начать исчезновение
func start_scale_out():
	scaleTweenNode.interpolate_property(bodyNode, "scale", bodyNode.scale, Vector2(0,0), inOutTweenDuration, Tween.TRANS_LINEAR)
	scaleTweenNode.start()


# смена режима освещённости
# вызывается по сигналу GameField - lightModeChanged
func set_light_mode(_setImmediately = false):
	var newAlpha = 1 if Global.isLightOn else 0
	if _setImmediately:
		modulate.a = newAlpha
	else:
		var newModulate = Color(modulate.r, modulate.g, modulate.b, newAlpha)
		lightModeTweenNode.interpolate_property(self, "modulate", modulate, newModulate, Global.lightModeChangeDuration)
		lightModeTweenNode.start()


# уничтожиться
func destroy():
	queue_free()
