extends Control

@onready var host_button = $"Panel/Host Button"
@onready var join_button = $"Panel/Join Button"

@onready var ip_address = $"Panel/IP Address"

# Called when the node enters the scene tree for the first time.
func _ready():
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_host_pressed():
	ConnectionOptions.setHost(true)
	startGame()
	
func _on_join_pressed():
	var ip:String = "localhost"

	if ip_address.text != "":
		ip = ip_address.text
		
	ConnectionOptions.setIP(ip)
	startGame()

func startGame():
	# Changes root of tree to main.tscn
	get_tree().change_scene_to_file("res://main.tscn")
