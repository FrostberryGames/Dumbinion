extends BaseCard

func action():
	game.player_side.prompt_multiple_cards(callback)
	game.set_alert("Discard cards","Waiting for "+game.cur_uname+" to discard cards")
func callback(cards):
	for i in cards:
		game.player_side.discard_card(i)
	game.player_side.draw_cards(len(cards))
	action_finished.call()
