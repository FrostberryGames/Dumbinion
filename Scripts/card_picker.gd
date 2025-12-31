extends Panel
class_name CardPicker

@onready
var submit_button = $VBoxContainer/HBoxContainer/SubmitButton
@onready
var card_picker = $VBoxContainer/CardPickerContainer
@onready
var info_label = $VBoxContainer/Label
var origin:Node
var required=false
var num_selected=0
var num_cards=0
var callback:Callable
var return_when_done=true

func placeholder(_x):
	return true

func pick_cards_callback(card):
	if !card.selected:
		if num_selected < num_cards:
			card.selected = true
			card_picker.queue_sort()
			num_selected+=1
			if required and num_selected == num_cards:
				submit_button.disabled=false
	else:
		card.selected = false
		num_selected-=1
		card_picker.queue_sort()
		if required:
			submit_button.disabled = true
	update_info_label()

func update_info_label():
	info_label.text= str(num_selected) +"/"+str(num_cards)

func pick_cards(callback,cards,num=999,parent=null,return_when_done=true,needed=false,filter:Callable=placeholder):
	show()
	submit_button.show()
	info_label.show()
	self.callback=callback
	self.return_when_done=return_when_done
	origin=parent
	num_selected=0
	required=needed
	num_cards = num
	submit_button.disabled=required
	for card:BaseCard in cards:
		if origin ==null:
			origin=card.get_parent()
		card.reparent_and_move(card_picker)
		if filter.call(card):
			card.card_selected.connect(pick_cards_callback.bind(card))
			card.prompt_select()
	update_info_label()

func unprompt_cards():
	for c in card_picker.get_children():
		if c.card_selected.is_connected(pick_cards_callback):
			c.card_selected.disconnect(pick_cards_callback)
		c.unprompt_select()
		


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	info_label.hide()
	for i in $VBoxContainer/HBoxContainer.get_children():
		i.hide()


func _on_submit_button_pressed() -> void:
	submit_button.hide()
	unprompt_cards()
	var cards=[]
	for i in card_picker.get_children():
		if i.selected:
			cards.append(i)
			i.selected=false
	if return_when_done:
		for i in card_picker.get_children():
			i.reparent_and_move(origin)
		hide()
		info_label.hide()
	callback.call(cards)
	card_picker.queue_sort()
