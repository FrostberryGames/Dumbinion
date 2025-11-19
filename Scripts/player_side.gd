extends HBoxContainer

@onready
var deck =$Deck/Margin/DeckContainer
@onready
var discard = $Discard/Margin/DiscardPileContainer
@onready
var hand = $Hand/Margin/HandContainer

signal card_selected(card)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
func disconector(card):
	unpromt_cards_from_hand()
	card_selected.emit(card)
	
func unpromt_cards_from_hand():
	for c in hand.get_children():
		if c.card_selected.is_connected(disconector):
			c.card_selected.disconnect(disconector)
		c.unprompt_select()

func placeholder(x):
	return x

func prompt_cards_from_hand(filter:Callable=placeholder):
	for c in filter.call(hand.get_children()):
		c.prompt_select()
		c.card_selected.connect(disconector.bind(c))
	
func add_card_to_hand(card):
	card.reparent(hand)
	
func discard_card(card):
	if !card:
		for c in hand.get_children():
			c.reparent(discard)
		return
	card.reparent(discard)
	
func top_deck(card):
	card.reparent(deck)
	
func shuffle_discard():
	var cards = discard.get_children()
	cards.shuffle()
	for c in cards:
		c.reparent(deck)
	
func draw_cards(num):
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
