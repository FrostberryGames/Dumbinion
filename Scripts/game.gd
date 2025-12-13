extends Node

signal turn_finished
@onready
var kingdom = $PlayerUI/Field
@onready
var player_side = $PlayerUI/PlayerSide
@onready
var phase_end_button = $PlayerUI/PhaseEndButton
@onready
var play_field = $PlayerUI/Field/Play/Margin/GridContainer
var buys = 0
var actions = 0
var cur_uname= ""
var dollars = 0
var card_ind=0
var phase = ""
var vp = 3

func _ready() -> void:
	phase_end_button.disabled=true

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
	update_vp(player_side.count_vp())
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

func card_keyword_filter(card:BaseCard,keyword):
	return keyword in card.cardKeywords

@rpc("any_peer","reliable")
func clear_play_area():
	for i:Node in play_field.get_children():
		i.queue_free()

@rpc("any_peer","reliable")
func start_turn():
	buys=1
	actions=1
	dollars=0
	phase_end_button.disabled=false
	begin_action()
	update_text.rpc(actions,buys,dollars)

func begin_action():
	set_phase_name.rpc("Action Phase")
	phase_end_button.text="End Actions"
	phase="action"
	if not player_side.prompt_cards_from_hand(action_card_played,card_keyword_filter.bind("action")):
		begin_buy_phase()

func begin_buy_phase():
	set_phase_name.rpc("Buy Phase")
	kingdom.prompt_select(card_bought,dollars)
	phase="buy"
	phase_end_button.text = "End Buys"
	player_side.prompt_cards_from_hand(treasure_played,card_keyword_filter.bind("treasure"))

@rpc("any_peer","reliable")
func card_to_play_area(card_scene):
	var card = load(card_scene).instantiate()
	card.name="played_card"+str(play_field.get_child_count())
	play_field.add_child(card)

func action_card_played(card:BaseCard):
	actions-=1
	actions+=card.actions
	buys+=card.buys
	dollars+=card.money
	card.reparent_and_move(play_field)
	card_to_play_area.rpc(card.scene_file_path)
	player_side.draw_cards(card.cards)
	update_text.rpc(actions,buys,dollars)
	if actions<=0:
		begin_buy_phase()
		return
	begin_action()
	
func end_buy_phase():
	
	kingdom.unprompt_select()
	player_side.unprompt_cards_from_hand()
	end_turn()
	
func end_action_phase():
	player_side.unprompt_cards_from_hand()
	begin_buy_phase()

func take_card_from_kingdom(kingdom_card):
	var new_card = kingdom_card.duplicate()
	new_card.name = cur_uname+str(card_ind)
	card_ind+=1
	new_card.hide_quantity()
	return new_card

func treasure_played(card:BaseCard):
	dollars+=card.money
	update_text.rpc(actions,buys,dollars)
	card.reparent_and_move(play_field)
	card_to_play_area.rpc(card.scene_file_path)
	player_side.prompt_cards_from_hand(treasure_played,card_keyword_filter.bind("treasure"))
	card.unprompt_select()
	kingdom.prompt_select(card_bought,dollars)

func card_bought(card:BaseCard):
	dollars -= card.cost
	buys-=1
	player_side.discard_card(take_card_from_kingdom(card))
	if buys > 0:
		kingdom.prompt_select(card_bought,dollars)
		update_text.rpc(actions,buys,dollars)
	else:
		end_turn()


func _on_phase_end_button_pressed() -> void:
	if phase =="action":
		end_action_phase()
	elif phase == "buy":
		end_buy_phase()
