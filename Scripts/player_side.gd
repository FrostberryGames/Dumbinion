extends HBoxContainer

@onready
var deck =$Deck/Margin/DeckContainer
@onready
var discard = $Discard/Margin/DiscardPileContainer
@onready
var hand = $Hand/Margin/HandContainer
var card_callback=null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func disconector(card):
	unprompt_cards_from_hand()
	card_callback.call(card)
	
func unprompt_cards_from_hand():
	for c in hand.get_children():
		if c.card_selected.is_connected(disconector):
			c.card_selected.disconnect(disconector)
		c.unprompt_select()

func placeholder(_x):
	return true

func prompt_cards_from_hand(callback,filter:Callable=placeholder):
	card_callback=callback
	var empty=true
	for c in hand.get_children():
		if not filter.call(c):
			continue
		empty=false
		c.prompt_select()
		c.card_selected.connect(disconector.bind(c))
	return not empty
	
func add_card_to_hand(card):
	card.reparent(hand)
	
func discard_card(card:BaseCard=null):
	if !card:
		for c in hand.get_children():
			c.reparent(discard)
		return
	if card.get_parent():
		card.reparent(discard)
	else:
		discard.add_child(card)
	
func top_deck(card):
	card.reparent(deck)
	
func shuffle_discard():
	var cards = discard.get_children()
	cards.shuffle()
	for c in cards:
		c.reparent(deck)
	
func draw_cards(num):
	if num<=0:
		return
	var list =deck.get_children()
	list.reverse()
	for c in list:
		c.reparent(hand)
		num-=1
		if num ==0:
			break
	
	if num>0:
		if(discard.get_child_count()==0):
			return
		shuffle_discard()
		draw_cards(num)
