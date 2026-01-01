extends BaseCard

func action():
	game.merchant_num+=1
	action_finished.call()
