extends BaseCard


func poacher_played():
	game.player_side.prompt_multiple_cards(callback,game.kingdom.empty_piles,true)
	game.set_alert("Select "+str(game.kingdom.empty_piles)+" card to discard","Waiting for "+game.cur_uname+" to discard cards")
func callback(cards):
	for i in cards:
		game.player_side.discard_card(i)
	action_finished.call()
