extends BaseCard


func action():
	game.player_side.prompt_multiple_cards(callback,4)
	game.set_alert("Trash up to 4 cards","Waiting for "+game.cur_uname+" to trash cards")
func callback(cards):
	for i:BaseCard in cards:
		game.trash_card(i)
	action_finished.call()
