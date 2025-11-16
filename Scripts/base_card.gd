extends PanelContainer

@export var actionName:String
@export var cards:int
@export var actions:int
@export var buys:int
@export var money:int
@export var cost:int
@export var cardDesc:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/CardDesc.text = cardDesc
	$CardCost.text = str(cost)+"$"
	var effects = ""
	if cards:
		effects+="+"+str(cards)+" card\n"
	if actions:
		effects+="+"+str(actions)+" actions\n"
	if buys:
		effects+="+"+str(buys)+" buys\n"
	if money:
		effects+="+"+str(money)+"$\n"
	$VBoxContainer/CardEffects.text = effects.trim_suffix("\n")
	
	hide_info()
	show_info()

func hide_info():
	$VBoxContainer/CardDesc.hide()
	$VBoxContainer/CardEffects.hide()
	
func show_info():
	if($VBoxContainer/CardDesc.text):
		$VBoxContainer/CardDesc.show()
	if($VBoxContainer/CardEffects.text):
		$VBoxContainer/CardEffects.show()
