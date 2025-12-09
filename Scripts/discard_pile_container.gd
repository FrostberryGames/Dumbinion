extends Container


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_sort_children() -> void:
	var spacing=0
	for c in get_children():
		if(spacing==0):
			custom_minimum_size.x = c.size.x
		fit_child_in_rect(c,Rect2(Vector2(0,spacing),c.get_transform().get_scale()))
		spacing+=2
		c.hide_info()
