extends BaseCard

func action():
	game.player_side.prompt_cards_from_hand(callback)
	game.set_alert("Choose a card to trash","Waiting for "+game.cur_uname+" to trash a card")

func callback(card):
	game.trash_card(card)
	game.kingdom.prompt_select(callback2,card.cost+2)
	game.set_alert("Choose a card to gain","Waiting for "+game.cur_uname+" to gain a card")


func callback2(card):
	game.gain_card(card)
	action_finished.call()
