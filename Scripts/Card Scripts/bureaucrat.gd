extends BaseCard
class_name Bureaucrat

func action():
	game.gain_card(game.silver)
	game.start_attack(action_finished,actionName)

static func attack(game:Game):
	var v_cards = game.player_side.hand.get_children().filter(Game.card_keyword_filter.bind("victory"))
	if !v_cards:
		game.end_attack()
	if len(v_cards)==1:
		game.player_side.top_deck(v_cards[0])
		game.end_attack()
		return
	game.set_alert("Select a victory card to top deck")
	game.player_side.prompt_cards_from_hand(attack_callback.bind(game),Game.card_keyword_filter.bind("victory"))
	
	
static func attack_callback(card,game):
	game.set_alert("Waiting for players to resolve the attack")
	game.player_side.top_deck(card)
	game.end_attack()
