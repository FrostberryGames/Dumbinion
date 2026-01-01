extends BaseCard
class_name Witch

func action():
	game.start_attack(action_finished,actionName)
	
static func attack(game:Game):
	game.gain_card(game.curse)
	game.end_attack()
	
