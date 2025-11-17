extends Node

# A key-pair dictionary with the key being the player's user and the values being:
# [0] = victory points
# [1] = their full deck with all of their cards
# [2] = their current hand
# [3] = their current discard pile
# [4] = their current deck (full deck - current hand - discard pile)
var Players := {
	"Bob" : [0, [], [], [], []],
	"Rob" : [0, [], [], [], []],
	"Cob" : [0, [], [], [], []],
	"Simon" : [0, [], [], [], []],
}

var turn := 0

func _init_game() -> void:
	print("Game Started")
	Players = _shuffle_dict(Players)
	for Player in Players:
		Players[Player][0] = 0
		Players[Player][1] = ["copper", "copper", "copper", "copper", "copper", "copper", "copper", "estate", "estate", "estate"]
		Players[Player][2] = []
		Players[Player][3] = []
		Players[Player][4] = []
		
	print(Players)

# This function is only called for shuffling the player dictionary
func _shuffle_dict(dict) -> Dictionary:
	var shuffled_dict = {}
	for i in dict.size():
		var randkey = randi_range(0, len(dict) - 1)
		shuffled_dict.set(dict.keys()[randkey], dict.values()[randkey])
		dict.erase(dict.keys()[randkey])
		
	return shuffled_dict
