extends PanelContainer
class_name BaseCard

signal card_selected
@export var actionName:String
@export var cardTags:String
@export var cards:int
@export var actions:int
@export var buys:int
@export var money:int
@export var cost:int
@export var cardDesc:String
@export var cardKeywords:String
@export var quantity = 10
var disabled = false
var moving = false
var selected = false
var game:Game

func prompt_select():
	if(disabled):
		return
	$Button.show()
	
static func attack(game:Game):
	pass
		
func start_react(game):
	self.game=game
	reaction()
		
func reaction():
	game.attack_callback.call(self)
		
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
	$VBoxContainer/Panel/Label.text = cardTags
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
	$VBoxContainer/Panel.hide()
	
func show_info():
	$VBoxContainer/Panel.show()
	if "treasure" in cardKeywords or "victory" in cardKeywords:
		return
	if($VBoxContainer/CardDesc.text):
		$VBoxContainer/CardDesc.show()
	if($VBoxContainer/CardEffects.text):
		$VBoxContainer/CardEffects.show()


func _on_button_pressed() -> void:
	card_selected.emit()

func start_action(g:Game):
	game=g
	action()
	
func action():
	game.begin_action()

func finish_reparent():
	moving=false
	if get_parent() is Container:
		get_parent().sort_children.emit()

func reparent_and_move(destination,speed=0.5):
	moving=true
	hide_info()
	reparent(destination)
	await get_tree().create_timer(0.01).timeout
	if(get_parent()!=destination):
		return
	var tween:Tween=get_tree().create_tween()
	var position_end = destination.get_child_position(self)
	var duration_in_seconds = speed
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", position_end, duration_in_seconds).set_trans(Tween.TRANS_CUBIC)
	tween.tween_callback(finish_reparent) # wait until move animation is complete
