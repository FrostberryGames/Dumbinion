extends BaseCard

func action():
	if not game.player_side.prompt_cards_from_hand(callback,Game.card_keyword_filter.bind("copper")):
		game.begin_action()
	else:
		game.set_alert("Select 1 copper to trash","Waiting for "+game.cur_uname+" to trash a copper")

func callback(card):
	game.trash_card(card)
	game.dollars+=3
	game.update_turn_info()
	game.begin_action()
