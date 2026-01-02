extends Node
class_name Game

signal turn_finished
@onready
var kingdom:Kingdom = $PlayerUI/Field
@onready
var player_side:PlayerSide = $PlayerUI/PlayerSide
@onready
var phase_end_button = $PlayerUI/PhaseEndButton
@onready
var play_field = $PlayerUI/Field/Play/Margin/GridContainer
@onready
var card_picker:CardPicker = $PlayerUI/CardPicker
@onready
var gold = $PlayerUI/Field/Resources/Margin/ScrollContainer/Grid/Gold
@onready
var silver = $PlayerUI/Field/Resources/Margin/ScrollContainer/Grid/Silver
@onready
var curse = $PlayerUI/Field/Resources/Margin/ScrollContainer/Grid/Curse
var buys = 0
var actions = 0
var cur_uname= ""
var dollars = 0
var card_ind=0
var phase = ""
var vp = 3
var merchant_num = 0
var attack_callback:Callable
var attack_num=0
var attack_finished:Callable
var attacking_id
var empty_piles = 0
var game_over = false
var card_registry={
	"bureaucrat":Bureaucrat,
	"witch":Witch,
	"bandit":Bandit,
	"milita":Milita
}

@rpc("any_peer","call_local","reliable")
func increase_empty_piles():
	empty_piles+=1

@rpc("any_peer","reliable")
func attack_players(card_name):
	attacking_id=multiplayer.get_remote_sender_id()
	attack_callback=card_registry[card_name].attack
	var cards = player_side.hand.get_children().filter(card_keyword_filter.bind("ATK-REACTION"))
	if cards:
		set_alert("Select a card, or none, to react with")
		card_picker.pick_cards(reaction_callback,cards,1)
	else:
		attack_callback.call(self)

func end_attack():
	finished_attack.rpc_id(attacking_id)

func reaction_callback(cards):
	if !cards:
		attack_callback.call(self)
		return
	cards[0].start_react(self)

func start_attack(callback,card_name):
	attack_num=0
	attack_finished=callback
	set_alert("Waiting for players to resolve the attack")
	attack_players.rpc(card_name)

@rpc("any_peer","reliable")
func finished_attack():
	attack_num+=1
	if attack_num==len(multiplayer.get_peers()):
		attack_finished.call()

func _ready() -> void:
	phase_end_button.disabled=true

@rpc("any_peer","call_remote","reliable")
func update_alert(msg):
	$PlayerUI/HBoxContainer/Alert.text = msg

func set_alert(msg,alt_msg=null):
	$PlayerUI/HBoxContainer/Alert.text = msg
	if alt_msg:
		update_alert.rpc(alt_msg)

func update_vp(num):
	vp = num
	for i in $PlayerUI/Scoreboard.get_children():
		if i.is_multiplayer_authority():
			i.set_vp.rpc(num)

func end_turn():
	phase_end_button.text="..."
	phase_end_button.disabled=true
	phase="enemy turn"
	clear_play_area.rpc()
	for i in play_field.get_children():
		i.reparent_and_move(player_side.discard)
	if game_over:
		_on_field_game_over.rpc()
	player_side.discard_card()
	player_side.draw_cards(5)
	turn_finished.emit()

@rpc("any_peer","call_local","reliable")
func update_text(a,b,d):
	$PlayerUI/TurnInfo/VBoxContainer/ResourcesInfo.text = "{0} Actions, {1} Buys, {2} Coins".format([a,b,d])

@rpc("any_peer","call_local","reliable")
func set_phase_name(text):
	$PlayerUI/TurnInfo/VBoxContainer/PhaseText.text=text

@rpc("any_peer","call_local","reliable")
func set_turn_name(uname):
	cur_uname=uname
	$PlayerUI/TurnInfo/VBoxContainer/TurnName.text = uname+"'s Turn"

static func card_keyword_filter(card:BaseCard,keyword):
	return keyword in card.cardKeywords

@rpc("any_peer","reliable")
func clear_play_area():
	for i:Node in play_field.get_children():
		i.queue_free()

@rpc("any_peer","reliable")
func start_turn():
	buys=1
	actions=1
	dollars= 10 if OS.is_debug_build() else 0
	merchant_num = 0
	phase_end_button.disabled=false
	begin_action()
	update_turn_info()

func begin_action():
	phase_end_button.disabled=false
	if actions<=0 or not player_side.prompt_cards_from_hand(action_card_played,card_keyword_filter.bind("action")):
		begin_buy_phase()
		return
	set_phase_name.rpc("Action Phase")
	phase_end_button.text="End Actions"
	phase="action"
	set_alert("Play an action card","Waiting for "+cur_uname+" to play an action card")

func begin_buy_phase():
	set_phase_name.rpc("Buy Phase")
	kingdom.prompt_select(card_bought,dollars)
	set_alert("Buy a card","Waiting for "+cur_uname+" to buy a card")
	phase="buy"
	phase_end_button.text = "End Buys"
	player_side.prompt_cards_from_hand(treasure_played,card_keyword_filter.bind("treasure"))

@rpc("any_peer","reliable")
func card_to_play_area(card_scene):
	var card = load(card_scene).instantiate()
	card.name="played_card"+str(play_field.get_child_count())
	$"Outer area".add_child(card)
	card.reparent_and_move(play_field)

func trash_card(card):
	card.show_card()
	card.reparent_and_move($"Outer area",1.5,true)
	GlobalAudio._play_trashed_sfx.rpc()

func update_turn_info():
	update_text.rpc(actions,buys,dollars)

@rpc("any_peer","reliable")
func other_players_draw_cards(num):
	player_side.draw_cards(num)

func action_card_played(card:BaseCard,callback=begin_action,bring_to_play=true):
	phase_end_button.disabled=true
	actions-=1
	actions+=card.actions
	buys+=card.buys
	dollars+=card.money
	if bring_to_play:
		card.reparent_and_move(play_field)
		card_to_play_area.rpc(card.scene_file_path)
	player_side.draw_cards(card.cards)
	update_turn_info()
	card.action_finished=callback
	card.start_action(self)

func end_buy_phase():
	
	kingdom.unprompt_select()
	player_side.unprompt_cards_from_hand()
	end_turn()
	
func end_action_phase():
	player_side.unprompt_cards_from_hand()
	begin_buy_phase()

@rpc("any_peer","reliable")
func move_card_out(card_path,pos):
	var card = load(card_path).instantiate()
	card.name = cur_uname+str(card_ind)
	card_ind+=1
	card.hide_quantity()
	add_child(card)
	card.show()
	card.global_position = pos
	card.reparent_and_move($"Outer area",3)

func take_card_from_kingdom(kingdom_card):
	if kingdom_card.disabled:
		return
	kingdom_card.decrease_quantity.rpc()
	if kingdom_card.disabled:
		increase_empty_piles.rpc()
		if empty_piles>=3 or kingdom_card.name == "Province":
			game_over=true
	move_card_out.rpc(kingdom_card.scene_file_path,kingdom_card.global_position)
	var new_card = kingdom_card.duplicate()
	new_card.name = cur_uname+str(card_ind)
	card_ind+=1
	new_card.hide_quantity()
	add_child(new_card)
	new_card.global_position = kingdom_card.global_position
	return new_card

func gain_card(card):
	if card.name == "Curse":
		GlobalAudio._play_curse_sfx()
	player_side.discard_card(take_card_from_kingdom(card))
	update_vp(player_side.count_vp())

func treasure_played(card:BaseCard):
	dollars+=card.money
	if "silver" in card.cardKeywords:
		dollars+=merchant_num
		merchant_num = 0
	update_turn_info()
	card.reparent_and_move(play_field)
	card_to_play_area.rpc(card.scene_file_path)
	player_side.prompt_cards_from_hand(treasure_played,card_keyword_filter.bind("treasure"))
	card.unprompt_select()
	kingdom.prompt_select(card_bought,dollars)

func card_bought(card:BaseCard):
	dollars -= card.cost
	buys-=1
	gain_card(card)
	if buys > 0:
		update_turn_info()
		begin_buy_phase()
	else:
		end_turn()

func _on_phase_end_button_pressed() -> void:
	if phase =="action":
		end_action_phase()
	elif phase == "buy":
		end_buy_phase()

@rpc("any_peer","call_local","reliable")
func _on_field_game_over() -> void:
	var highest = 0
	var winner = ""
	for i in $PlayerUI/Scoreboard.get_children():
		if i.vp > highest:
			highest = i.vp
			winner=i.username
		elif i.vp == highest:
			winner = winner+ " "+i.username
	$WinLabel.text = winner + " WINS!"
	for i in get_children():
		i.hide()
	$WinLabel.show()
