extends Area2D

onready var pointNode = $PointPath/PathFollow2D/Point
onready var pathFollowNode = $PointPath/PathFollow2D
onready var lightModeTweenNode = $LightModeTween
onready var spriteNode = $ColorRect

export var width = 16 


# смена режима освещённости
# вызывается по сигналу GameField - lightModeChanged
func set_light_mode(_setImmediately = false):
	var newAlpha = 1 if Global.isLightOn else 0
	if _setImmediately:
		spriteNode.modulate.a = newAlpha
	else:
		var newModulate = Color(spriteNode.modulate.r, spriteNode.modulate.g, spriteNode.modulate.b, newAlpha)
		lightModeTweenNode.interpolate_property(spriteNode, "modulate", spriteNode.modulate, newModulate, Global.lightModeChangeDuration)
		lightModeTweenNode.start()
