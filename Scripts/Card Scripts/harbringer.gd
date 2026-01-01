extends BaseCard

func action():
	if game.player_side.discard.get_child_count()==0:
		action_finished.call()
		return
	game.card_picker.pick_cards(callback,game.player_side.discard.get_children(),1,null,true,true)
	game.set_alert("Select a card to top deck","Waiting for "+game.cur_uname+" to top deck a card")
	
func callback(card):
	if card:
		game.player_side.top_deck(card[0])
	action_finished.call()
