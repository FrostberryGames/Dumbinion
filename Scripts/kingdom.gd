extends HBoxContainer
class_name Kingdom

var cur_card:PanelContainer = null
var info_showing = false
var prompt_callback:Callable
var prompted = false

func card_pressed(card:BaseCard):
	GlobalAudio._play_buy_sfx()
	unprompt_select()
	prompt_callback.call(card)

func mouse_entered_card(card:PanelContainer):
	cur_card=card
	
func mouse_exited_card():
	hide_card_info()
	cur_card=null

func get_all_children():
	return $Kingdom/Margin/Grid.get_children() + $Resources/Margin/ScrollContainer/Grid.get_children()

func placeholder(_card):
	return true

func prompt_select(callback,cost:int=9999,filter=placeholder):
	prompt_callback = callback
	if prompted:
		unprompt_select()
	for i in get_all_children():
		if i.cost <= cost and filter.call(i):
			i.prompt_select()
			prompted=true
			
func unprompt_select():
	prompted=false
	for i in get_all_children():
		i.unprompt_select()
	

@rpc("any_peer","call_local","reliable")
func generate_kingdom(cards:Array):
	var j=0
	for i in cards:
		var card:PanelContainer = load(i).instantiate()
		card.name = "card"+str(j)
		j+=1
		card.mouse_entered.connect(mouse_entered_card.bind(card))
		card.card_selected.connect(card_pressed.bind(card))
		card.mouse_exited.connect(mouse_exited_card)
		$Kingdom/Margin/Grid.add_child(card)
		card.show_quantity()
		
		card.hide_info()

func hide_card_info():
	if info_showing:
		cur_card.hide_info()
		info_showing=false
					
func toggle_card_info():
	if info_showing:
		cur_card.hide_info()
		info_showing=false
	else:
		cur_card.show_info()
		info_showing=true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton  and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if cur_card:
				toggle_card_info()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for card in $Resources/Margin/ScrollContainer/Grid.get_children():
		card.show_quantity()
		card.hide_info()
		card.card_selected.connect(card_pressed.bind(card))
	
