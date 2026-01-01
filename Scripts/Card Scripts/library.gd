extends BaseCard

func action(keep=null):
	if not keep == null:
		if keep:
			game.player_side.draw_cards(1)
		else:
			game.player_side.discard_card(game.player_side.get_cards_off_deck(1)[0])
	while game.player_side.hand.get_child_count()<7:
		var card = game.player_side.get_cards_off_deck(1)[0]
		if not "action" in card.cardKeywords:
			game.player_side.draw_cards(1)
			continue
		game.set_alert("Choose to keep of discard this card","Waiting for "+game.cur_uname+" to decide whether to keep a card or not")
		game.card_picker.pick_yes_no(action,"Keep","Discard",[card])
		return
	action_finished.call()
