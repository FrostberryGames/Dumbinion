extends Container


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func get_child_position(card):
	var spacing=0
	for c in get_children():
		if c==card:
			return Vector2(spacing/4*120,spacing%4*80+spacing/4%2*30) + global_position
		spacing+=1

func _on_sort_children() -> void:
	var spacing=0
	for c in get_children():
		if c.moving:
			continue
		fit_child_in_rect(c,Rect2(Vector2(spacing/4*120,spacing%4*80+spacing/4%2*30),c.get_transform().get_scale()))
		spacing+=1
		c.hide_info()
