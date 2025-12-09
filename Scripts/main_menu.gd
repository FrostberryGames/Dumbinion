extends VBoxContainer

signal join_game(username:String,ip:String)
signal host_game(username:String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_username():
	return $LineEdit.text

func _on_host_button_pressed() -> void:
	host_game.emit()


func _on_join_button_pressed() -> void:
	if $LineEdit.text:
		join_game.emit($Ip.text)
