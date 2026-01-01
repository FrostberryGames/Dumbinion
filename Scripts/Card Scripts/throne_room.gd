extends BaseCard

var throne_card:BaseCard

func action():
	game.set_alert("Select an action card to play twice","Waiting for "+game.cur_uname+" to select an action card")
	if !game.player_side.prompt_multiple_cards(callback,1,false,Game.card_keyword_filter.bind("action")):
		action_finished.call()
	
func callback(cards):
	if !cards:
		return
	game.actions+=1
	throne_card=cards[0]
	game.action_card_played(throne_card,callback2)
	
func callback2():
	game.actions+=1
	game.action_card_played(throne_card,game.begin_action,false)
	action_finished.call()
