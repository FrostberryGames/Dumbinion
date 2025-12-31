extends Node

class Player:
	var username:String
	var id
	
	func _init(user,pid) -> void:
		username= user
		id = pid

const PORT = 33678

@export var kingdom_cards:Array[String]
@export var user_plate:PackedScene
var peer = ENetMultiplayerPeer.new()
var peer_userpalate = null
var players:Array[Player]=[]
var cur_turn=0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(peer_connected)
	show_menu()
	$Lobby/LobbyButtons/ReadyButton.pressed.connect(ready_button_pressed)
	
@rpc("any_peer","reliable")
func next_turn():
	cur_turn+=1
	if cur_turn>=len(players):
		cur_turn=0
	$Game.set_turn_name.rpc(players[cur_turn].username)
	if players[cur_turn].id==1:
		$Game.start_turn()
	else:
		$Game.start_turn.rpc_id(players[cur_turn].id)

func start_button_pressed():
	for i:Node in $Lobby/UserPlateContainer.get_children():
		if not i.readied:
			return
	players.shuffle()
	cur_turn=-1
	var card_list = []
	if OS.is_debug_build():
		kingdom_cards.reverse()
	else:
		kingdom_cards.shuffle()
	for i in range(10):
		card_list.append(kingdom_cards[i])
	$Game.kingdom.generate_kingdom.rpc(card_list)
	next_turn()
	start_game.rpc()
	
func ready_button_pressed():
	if peer_userpalate.readied:
		peer_userpalate.un_ready.rpc()
		$Lobby/LobbyButtons/ReadyButton.text="Ready"
	else:
		peer_userpalate.ready_up.rpc()
		$Lobby/LobbyButtons/ReadyButton.text="Not Ready"

func show_game():
	$MainMenu.hide()
	$Game.show()
	$Lobby.hide()

func show_menu():
	$MainMenu.show()
	$Game.hide()
	$Lobby.hide()
	
func show_lobby():
	$MainMenu.hide()
	$Game.hide()
	$Lobby.show()
	$Lobby/LobbyButtons/StartButton.disabled = not multiplayer.is_server()

@rpc("call_local","reliable")
func start_game():
	show_game()
	for i:Node in $Lobby/UserPlateContainer.get_children():
		i.reparent($Game/PlayerUI/Scoreboard)
		i.show_vp()

func _on_main_menu_host_game() -> void:
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer
	peer_userpalate = create_plate(multiplayer.get_unique_id())
	peer_userpalate.set_user($MainMenu.get_username())
	players.append(Player.new($MainMenu.get_username(),multiplayer.get_unique_id()))
	$Lobby/LobbyButtons/StartButton.pressed.connect(start_button_pressed)
	show_lobby()

func _on_main_menu_join_game(ip:String) -> void:
	peer.create_client(ip,PORT)
	multiplayer.multiplayer_peer = peer
	peer_userpalate = create_plate(multiplayer.get_unique_id())
	peer_userpalate.set_user($MainMenu.get_username())
	show_lobby()

func peer_connected(id):
	player_joined.rpc_id(id,$MainMenu.get_username(),peer_userpalate.readied)
	
@rpc("any_peer","reliable")
func player_joined(username,readied):
	var id = multiplayer.get_remote_sender_id()
	var plate = create_plate(id)
	plate.set_user(username)
	if multiplayer.is_server():
		players.append(Player.new(username,id))
	if readied:
		plate.ready_up()

func create_plate(id):
	var plate = user_plate.instantiate()
	plate.name = str(id)
	plate.show_ready()
	$Lobby/UserPlateContainer.add_child(plate)
	return plate


func _on_game_turn_finished() -> void:
	if multiplayer.is_server():
		next_turn()
		return
	next_turn.rpc_id(1)
