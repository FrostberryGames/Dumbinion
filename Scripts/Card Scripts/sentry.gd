extends BaseCard

func action():
	var cards = game.player_side.get_cards_off_deck(2)
	game.set_alert("Select cards to trash","Waiting for "+game.cur_uname+" to trash cards")
	game.card_picker.pick_cards(callback,cards,2,null,false)
	
	
func callback(cards):
	for i in cards:
		game.trash_card(i)
	if game.card_picker.card_picker.get_child_count()==0:
		action_finished.call()
		return
	game.set_alert("Select cards to discard","Waiting for "+game.cur_uname+" to discard cards")
	game.card_picker.pick_cards(callback2,game.card_picker.card_picker.get_children(),game.card_picker.card_picker.get_child_count(),null,false)
	
func callback2(cards):
	for i in cards:
		game.player_side.discard_card(i)
	if game.card_picker.card_picker.get_child_count()==0:
		action_finished.call()
		game.card_picker._ready()
		return
	if game.card_picker.card_picker.get_child_count()==1:
		game.player_side.top_deck(game.card_picker.card_picker.get_children()[0])
		game.card_picker._ready()
		action_finished.call()
		return
	game.set_alert("Change card order  Bottom  -  Top","Waiting for "+game.cur_uname+" to change card order")
	game.card_picker.pick_yes_no(callback3,"Swap card order","Keep card order",game.card_picker.card_picker.get_children(),true,game.player_side.deck)
	
func callback3(swap):
	if swap:
		var second_top = game.player_side.get_cards_off_deck(2)[1]
		game.player_side.deck.move_child(second_top,-1)
		game.player_side.deck.queue_sort()
	action_finished.call()
	
