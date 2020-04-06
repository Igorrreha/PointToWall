extends Node2D

var rotationTweenNode 
var rotationTimerNode


func _ready():
	rotationTweenNode = $RotationTween
	rotationTimerNode = $RotationTimer
	
	start_rotation()


func start_rotation():
	var rotationDuration = randi() % 4 + 1
	
	rotationTweenNode.interpolate_property(self, "rotation_degrees", rotation_degrees, randi() % 720 - 360, rotationDuration, Tween.TRANS_ELASTIC,Tween.EASE_IN_OUT)
	rotationTweenNode.start()
	
	rotationTimerNode.start(rotationDuration)
