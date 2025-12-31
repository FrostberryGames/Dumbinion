extends BaseCard

func reaction():
	game.set_alert("Waiting for players to resolve the attack")
	game.end_attack()
