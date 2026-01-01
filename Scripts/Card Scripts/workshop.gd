extends BaseCard

func action():
	game.kingdom.prompt_select(callback,4)

func callback(card):
	game.gain_card(card)
	action_finished.call()
