extends BaseCard

func action():
	game.player_side.prompt_cards_from_hand(callback1,Game.card_keyword_filter.bind("treasure"))
	game.set_alert("Select 1 Treasure to trash","Waiting for "+game.cur_uname+" to trash a treasure")
func callback1(card):
	game.trash_card(card)
	game.kingdom.prompt_select(callback2,card.cost+3,Game.card_keyword_filter.bind("treasure"))
	game.set_alert("Select 1 Treasure to gain","Waiting for "+game.cur_uname+" to buy a treasure")
func callback2(card):
	game.take_card_from_kingdom(card).reparent_and_move(game.player_side.hand)
	game.begin_action()
