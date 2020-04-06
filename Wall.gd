extends Area2D


var pointNode
var pathFollowNode
var pathFollowTweenNode


func _ready():
	pointNode = $PointPath/PathFollow2D/Point
	pathFollowNode = $PointPath/PathFollow2D


func _process(delta):
	# движение поинтов выключено
	#if not pointNode.isCatched:
		#pathFollowNode.offset += pointNode.moveSpeed * delta
	pass
