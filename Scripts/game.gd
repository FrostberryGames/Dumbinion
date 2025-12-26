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
var merchant_num = 0

func _ready() -> void:
	phase_end_button.disabled=true

@rpc("any_peer","call_remote","reliable")
func update_alert(msg):
	$PlayerUI/HBoxContainer/Alert.text = msg

func set_alert(msg,alt_msg=null):
	$PlayerUI/HBoxContainer/Alert.text = msg
	update_alert.rpc(alt_msg if alt_msg else msg)

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
	if kingdom.game_over:
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

func card_keyword_filter(card:BaseCard,keyword):
	return keyword in card.cardKeywords

@rpc("any_peer","reliable")
func clear_play_area():
	for i:Node in play_field.get_children():
		i.queue_free()

@rpc("any_peer","reliable")
func start_turn():
	buys=1
	actions=2
	dollars=10
	merchant_num = 0
	phase_end_button.disabled=false
	begin_action()
	update_text.rpc(actions,buys,dollars)

func begin_action():
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
	play_field.add_child(card)

func trash_card(card):
	card.queue_free()

func cellar_played():
	player_side.prompt_multiple_cards(cellar_callback)
	set_alert("Discard cards","Waiting for "+cur_uname+" to discard cards")
func cellar_callback(cards):
	for i in cards:
		player_side.discard_card(i)
	player_side.draw_cards(len(cards))
	begin_action()

func chapel_played():
	player_side.prompt_multiple_cards(chapel_callback,4)
	set_alert("Trash up to 4 cards","Waiting for "+cur_uname+" to trash cards")
func chapel_callback(cards):
	for i:BaseCard in cards:
		trash_card(i)
	begin_action()

@rpc("any_peer","reliable")
func council_room_played():
	player_side.draw_cards(1)

func mine_played():
	player_side.prompt_cards_from_hand(mine_callback1,card_keyword_filter.bind("treasure"))
	set_alert("Select 1 Treasure to trash","Waiting for "+cur_uname+" to trash a treasure")
func mine_callback1(card):
	trash_card(card)
	kingdom.prompt_select(mine_callback2,card.cost+3,card_keyword_filter.bind("treasure"))
	set_alert("Select 1 Treasure to gain","Waiting for "+cur_uname+" to buy a treasure")
func mine_callback2(card):
	player_side.hand.add_child(take_card_from_kingdom(card))
	begin_action()

func moneylender_played():
	if not player_side.prompt_cards_from_hand(moneylender_callback,card_keyword_filter.bind("copper")):
		begin_action()
	else:
		set_alert("Select 1 copper to trash","Waiting for "+cur_uname+" to trash a copper")
func moneylender_callback(card):
	trash_card(card)
	dollars+=3
	update_text.rpc(actions,buys,dollars)
	begin_action()

func poacher_played():
	player_side.prompt_multiple_cards(poacher_callback,kingdom.empty_piles,true)
	set_alert("Select "+str(kingdom.empty_piles)+" card to discard","Waiting for "+cur_uname+" to discard cards")
	
func poacher_callback(cards):
	for i in cards:
		player_side.discard_card(i)
	begin_action()

func action_card_played(card:BaseCard):
	actions-=1
	actions+=card.actions
	buys+=card.buys
	dollars+=card.money
	card.reparent_and_move(play_field)
	card_to_play_area.rpc(card.scene_file_path)
	player_side.draw_cards(card.cards)
	update_text.rpc(actions,buys,dollars)
	match card.actionName:
		"cellar":
			cellar_played()
		"chapel":
			chapel_played()
		"council room":
			council_room_played.rpc()
			begin_action()
		"merchant":
			merchant_num+=1
			begin_action()
		"mine":
			mine_played()
		"moneylender":
			moneylender_played()
		"poacher":
			if kingdom.empty_piles>0:
				poacher_played()
			else:
				begin_action()
		_:
			begin_action()
	
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
	move_card_out.rpc(kingdom_card.scene_file_path,kingdom_card.global_position)
	var new_card = kingdom_card.duplicate()
	new_card.name = cur_uname+str(card_ind)
	card_ind+=1
	new_card.hide_quantity()
	add_child(new_card)
	new_card.global_position = kingdom_card.global_position
	return new_card

func treasure_played(card:BaseCard):
	dollars+=card.money
	if "silver" in card.cardKeywords:
		dollars+=merchant_num
		merchant_num = 0
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
		update_text.rpc(actions,buys,dollars)
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
