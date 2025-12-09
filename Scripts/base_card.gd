extends PanelContainer
class_name BaseCard



signal card_selected
@export var actionName:String
@export var cards:int
@export var actions:int
@export var buys:int
@export var money:int
@export var cost:int
@export var cardDesc:String
@export var cardKeywords:String
var quantity = 10
var disabled = false

func prompt_select():
	if(disabled):
		return
	$Button.show()
		
func hide_card():
	$BackOfCard.show()
	
func show_card():
	$BackOfCard.hide()
		
@rpc("any_peer","call_local","reliable")
func decrease_quantity():
	quantity-=1
	$Quantity.text=str(quantity)
	if quantity <=0:
		disabled = true
		unprompt_select()
		hide_card()

func show_quantity():
	$Quantity.show()
	
func hide_quantity():
	$Quantity.hide()
	
func unprompt_select():
	$Button.hide()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Quantity.hide()
	$Quantity.text=str(quantity)
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
	show_card()
	unprompt_select()

func hide_info():
	$VBoxContainer/CardDesc.hide()
	$VBoxContainer/CardEffects.hide()
	
func show_info():
	if($VBoxContainer/CardDesc.text):
		$VBoxContainer/CardDesc.show()
	if($VBoxContainer/CardEffects.text):
		$VBoxContainer/CardEffects.show()


func _on_button_pressed() -> void:
	card_selected.emit()
