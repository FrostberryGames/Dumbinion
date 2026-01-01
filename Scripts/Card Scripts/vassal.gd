extends BaseCard

func action():
	var card = game.player_side.get_cards_off_deck(1)[0]
	if not "action" in card.cardKeywords:
		game.player_side.discard_card(card)
		action_finished.call()
		return
	game.card_picker.pick_yes_no(callback.bind(card),"Play card","Discard card",[card],true,game.player_side.discard)

func callback(play,card):
	if play:
		game.actions+=1
		game.action_card_played(card,action_finished)
		return
	action_finished.call()
