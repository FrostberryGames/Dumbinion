extends BaseCard

func action():
	game.set_alert("Select card to gain","Waiting for "+game.cur_uname+" to select a card")
	game.kingdom.prompt_select(callback,4)

func callback(card):
	game.gain_card(card)
	action_finished.call()
