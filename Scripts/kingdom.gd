extends PanelContainer

@export var cards: Array[PackedScene]
var cur_card:PanelContainer = null
var info_showing = false
var prompt_callback:Callable

func card_pressed(card:BaseCard):
	unprompt_select()
	card.decrease_quantity.rpc()
	prompt_callback.call(card)

func mouse_entered_card(card:PanelContainer):
	cur_card=card
	
func mouse_exited_card():
	hide_card_info()
	cur_card=null

func prompt_select(callback,cost:int=9999):
	prompt_callback = callback
	for i in $Margin/Grid.get_children():
		if i.cost <= cost:
			i.prompt_select()
			
func unprompt_select():
	for i in $Margin/Grid.get_children():
		i.unprompt_select()
	
func generate_kingdom():
	for i in range(10):
		var card:PanelContainer = cards.pick_random().instantiate()
		card.name = "card"+str(i)
		card.mouse_entered.connect(mouse_entered_card.bind(card))
		card.card_selected.connect(card_pressed.bind(card))
		card.mouse_exited.connect(mouse_exited_card)
		$Margin/Grid.add_child(card)
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
	generate_kingdom()
	unprompt_select()
	
