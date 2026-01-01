extends BaseCard

func reaction():
	GlobalAudio._play_block_sfx()
	game.set_alert("Waiting for players to resolve the attack")
	game.end_attack()
