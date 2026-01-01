extends BaseCard


func action():
	if game.empty_piles:
		game.player_side.prompt_multiple_cards(callback,game.empty_piles,true)
		game.set_alert("Select "+str(game.empty_piles)+" card to discard","Waiting for "+game.cur_uname+" to discard cards")
		return
	action_finished.call()

func callback(cards):
	for i in cards:
		game.player_side.discard_card(i)
	action_finished.call()
