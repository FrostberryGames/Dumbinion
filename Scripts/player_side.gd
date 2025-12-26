extends HBoxContainer

@onready
var deck =$Deck/Margin/DeckContainer
@onready
var discard = $Discard/Margin/DiscardPileContainer
@onready
var hand = $Hand/Margin/HandContainer
@onready
var submit_button = $"../HBoxContainer/SubmitButton"
var card_callback=null
var num_cards = 0
var num_selected = 0
var required = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shuffle_discard()
	draw_cards(5)
	
func selector(card):
	if !card.selected:
		if num_selected < num_cards:
			card.selected = true
			hand.queue_sort()
			num_selected+=1
			if required and num_selected == num_cards:
				submit_button.disabled=false
	else:
		card.selected = false
		num_selected-=1
		hand.queue_sort()
		if required:
			submit_button.disabled = true
	
func disconector(card):
	unprompt_cards_from_hand()
	card_callback.call(card)
	
func unprompt_cards_from_hand():
	for c in hand.get_children():
		if c.card_selected.is_connected(disconector):
			c.card_selected.disconnect(disconector)
		elif c.card_selected.is_connected(selector):
			c.card_selected.disconnect(selector)
		c.unprompt_select()

func placeholder(_x):
	return true

func prompt_multiple_cards(callback,num=999,needed=false,filter:Callable=placeholder):
	card_callback=callback
	num_cards=num
	required = needed
	num_selected=0
	submit_button.disabled=required
	var empty=true
	for c in hand.get_children():
		if not filter.call(c):
			c.unprompt_select()
			continue
		empty=false
		c.prompt_select()
		c.card_selected.connect(selector.bind(c))
	return not empty

func prompt_cards_from_hand(callback,filter:Callable=placeholder):
	card_callback=callback
	num_cards=0
	var empty=true
	for c in hand.get_children():
		if not filter.call(c):
			c.unprompt_select()
			continue
		empty=false
		c.prompt_select()
		c.card_selected.connect(disconector.bind(c))
	return not empty
	
func add_card_to_hand(card):
	card.reparent_and_move(hand)
	
func discard_card(card:BaseCard=null):
	unprompt_cards_from_hand()
	if !card:
		for c in hand.get_children():
			c.reparent_and_move(discard)
		return
	if card.get_parent():
		card.reparent_and_move(discard)
	else:
		discard.add_child(card)
	
func top_deck(card):
	card.reparent_and_move(deck)
	
func shuffle_discard():
	var cards = discard.get_children()
	cards.shuffle()
	for c in cards:
		c.reparent_and_move(deck)
	
func count_vp():
	var vps = 0
	for card:BaseCard in $Hand/Margin/HandContainer.get_children() + $Deck/Margin/DeckContainer.get_children() + $Discard/Margin/DiscardPileContainer.get_children():
		if "victory" in card.cardKeywords:
			vps+=card.actions
	return vps
	
func draw_cards(num):
	if num<=0:
		return
	var list =deck.get_children()
	list.reverse()
	for c in list:
		c.reparent_and_move(hand)
		num-=1
		if num ==0:
			break
	
	if num>0:
		if(discard.get_child_count()==0):
			return
		shuffle_discard()
		draw_cards(num)


func _on_submit_button_pressed() -> void:
	unprompt_cards_from_hand()
	var cards = []
	for i in hand.get_children():
		if i.selected:
			cards.append(i)
			i.selected=false
	hand.queue_sort()
	card_callback.call(cards)
	submit_button.disabled=true
