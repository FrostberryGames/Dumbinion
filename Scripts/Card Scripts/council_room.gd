extends BaseCard

func action():
	game.other_players_draw_cards.rpc(1)
	action_finished.call()
