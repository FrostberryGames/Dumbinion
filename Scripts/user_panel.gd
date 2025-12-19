extends PanelContainer

var readied = false
var vp = 0
var username = ""

func _ready() -> void:
	set_multiplayer_authority(int(name))
	un_ready()

func show_ready():
	$Ready.show()
	$VPs.hide()
	
func show_vp():
	$Ready.hide()
	$VPs.show()

@rpc("call_local","reliable")
func set_vp(num):
	vp = num
	$VPs.text = str(num) + " VP"

func set_user(uname):
	username = uname
	$Username.text = uname

@rpc("call_local","reliable")
func ready_up():
	$Ready.text = "Ready"
	$Ready.add_theme_color_override("font_color",Color.GREEN)
	readied=true
	
@rpc("call_local","reliable")
func un_ready():
	$Ready.text = "Not Ready"
	$Ready.add_theme_color_override("font_color",Color.RED)
	readied = false
