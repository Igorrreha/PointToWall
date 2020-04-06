extends Area2D

export var isCatched = false
export var moveSpeed = 100

signal point_catched


func _ready():
	$ColorRect.visible = not isCatched


# обработка поимки
func set_catched(value):
	if value:
		emit_signal("point_catched")
	elif isCatched:
		# смена позиции
		randomize()
		get_parent().unit_offset = randf()
	
	isCatched = value
	$ColorRect.visible = not value
