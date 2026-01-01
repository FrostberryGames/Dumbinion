extends BaseCard

var throne_card:BaseCard

func action():
	game.set_alert("Select an action card to play twice","Waiting for "+game.cur_uname+" to select an action card")
	if !game.player_side.prompt_cards_from_hand(callback,Game.card_keyword_filter.bind("action")):
		action_finished.call()
	
func callback(card):
	game.actions+=1
	throne_card=card
	game.action_card_played(throne_card,callback2)
	
func callback2():
	game.actions+=1
	game.action_card_played(throne_card,action_finished,false)
