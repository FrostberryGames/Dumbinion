extends Container

func get_child_position(card):
	var spacing:int
	var i = 0
	var width:int
	for c in get_children():
		c.show_card()
		if(!spacing):
			width = min(size.x,(c.size.x+15)*get_child_count())
			spacing=(width-c.size.x)/(get_child_count()-1)
		if c==card:
			return Vector2(spacing*i+(size.x-width)/2,50)+global_position
		i+=1

func _on_sort_children() -> void:	
	var spacing:int
	var i = 0
	var width:int
	for c in get_children():
		c.show_card()
		c.show_info()
		if c.moving:
			continue
		if(!spacing):
			width = min(size.x,(c.size.x+15)*get_child_count())
			spacing=(width-c.size.x)/(get_child_count()-1)
		fit_child_in_rect(c,Rect2(Vector2(spacing*i+(size.x-width)/2,10 if c.selected else 50),c.get_transform().get_scale()))
		i+=1
