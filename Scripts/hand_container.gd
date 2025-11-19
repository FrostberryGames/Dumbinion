extends Container


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



func _on_sort_children() -> void:
	var spacing:int
	var i = 0;
	for c in get_children():
		c.show_card()
		c.show_info()
		if(!spacing):
			spacing=(size.x-c.size.x)/(get_child_count()-1)
		fit_child_in_rect(c,Rect2(Vector2(spacing*i,(size.y-c.size.y)/2),c.get_transform().get_scale()))
		i+=1
		
