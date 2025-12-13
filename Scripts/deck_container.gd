extends Container


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func get_child_position(card):
	var spacing:int
	var i = 0;
	for c in get_children():
		if(get_child_count()==1):
			spacing = size.x-c.size.x
			i=1
		if(!spacing):
			spacing=(size.x-c.size.x)/(get_child_count()-1)
		if c==card:
			return Vector2(spacing*i,(size.y-c.size.y)/2)+global_position
		i+=1

func _on_sort_children() -> void:
	$"../Count".text = str(get_child_count())
	var spacing:int
	var i = 0;
	for c in get_children():
		c.hide_info()
		c.hide_card()
		if c.moving:
			continue
		if(get_child_count()==1):
			spacing = size.x-c.size.x
			i=1
		if(!spacing):
			spacing=(size.x-c.size.x)/(get_child_count()-1)
		fit_child_in_rect(c,Rect2(Vector2(spacing*i,(size.y-c.size.y)/2),c.get_transform().get_scale()))
		i+=1
