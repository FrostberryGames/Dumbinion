extends BaseCard
class_name Bandit

func action():
	game.gain_card(game.gold)
	game.start_attack(action_finished,actionName)

static func custom_filter(card):
	return "treasure" in card.cardKeywords and not "copper" in card.cardKeywords

static func attack(game:Game):
	var c = game.player_side.get_cards_off_deck(2)
	var treasures= c.filter(custom_filter)
	if len(treasures)>0:
		game.set_alert("Select a card to trash")
		game.card_picker.pick_cards(attack_callback.bind(game),treasures,1,game.player_side.discard,true,true)
		for i in c:
			if not i in treasures:
				game.player_side.discard_card(i)
		return
	for i in c:
		game.player_side.discard_card(i)
	game.end_attack()

static func attack_callback(card,game):
	if card:
		game.trash_card(card[0])
	game.end_attack()
