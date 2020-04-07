extends Node2D

var MoveCurveLinear = preload("res://enemies/path_curves/linear.tres")
var MoveCurveZigzag = preload("res://enemies/path_curves/zigzag.tres")

var moveTweenNode
var scaleTweenNode
var scaleOutTimerNode
var destroyTimerNode
var pathNode
var pathFollowNode
var bodyNode

var isMoveBackwards = true if randi() % 2 == 1 else false

var rotSpeed = randi() % 360 - 180

var moveDuration = randi() % 5 + 5
var inOutTweenDuration = 0.5


func _ready():
	
	bodyNode = $Path2D/PathFollow2D/Body
	moveTweenNode = $MoveTween
	scaleTweenNode = $ScaleTween
	pathNode = $Path2D
	pathFollowNode = $Path2D/PathFollow2D
	scaleOutTimerNode = $ScaleOutTimer
	destroyTimerNode = $DestroyTimer
	
	pathNode.curve = MoveCurveLinear if randi() % 3 == 1 else MoveCurveZigzag
	
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


# уничтожиться
func destroy():
	queue_free()
