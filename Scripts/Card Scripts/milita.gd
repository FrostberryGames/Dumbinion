extends BaseCard
class_name Milita

func action():
	game.start_attack(action_finished,actionName)
	
static func attack(game:Game):
	var num = game.player_side.hand.get_child_count()-3
	if num<=0:
		game.set_alert("Waiting for players to resolve the attack")
		game.end_attack()
	game.set_alert("Select "+str(num)+" cards to discard")
	game.player_side.prompt_multiple_cards(attack_callback.bind(game),num,true)
	
static func attack_callback(cards,game:Game):
	for i in cards:
		game.player_side.discard_card(i)
	game.set_alert("Waiting for players to resolve the attack")
	game.end_attack()
