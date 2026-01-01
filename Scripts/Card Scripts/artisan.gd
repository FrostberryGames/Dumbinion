extends BaseCard

func action():
	game.set_alert("Select card to gain","Waiting for "+game.cur_uname+" to select a card")
	game.kingdom.prompt_select(callback,5)

func callback(card):
	game.take_card_from_kingdom(card).reparent_and_move(game.player_side.hand)
	game.set_alert("Select card to top deck","Waiting for "+game.cur_uname+" to top deck a card")
	game.player_side.prompt_cards_from_hand(callback2)
	
func callback2(card):
	game.player_side.top_deck(card)
	action_finished.call()
