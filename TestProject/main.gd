extends Node3D

const Stage = preload("res://Levels/world.tscn")
const Player = preload("res://Player/player_instance.tscn")

var enet_peer = ENetMultiplayerPeer.new()
const PORT = 9159


func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
		
# Called when the node enters the scene tree for the first time.
func _ready():
	if ConnectionOptions.getHost():
		basic_host()
	else:
		basic_join()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func basic_host():
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(delete_player)
	spawn_level()
	add_player(multiplayer.get_unique_id())
	
func basic_join():
	enet_peer.create_client(ConnectionOptions.getIP(), PORT)
	multiplayer.multiplayer_peer = enet_peer
	
func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	
func spawn_level():
	var stage = Stage.instantiate()
	add_child(stage)
	
func delete_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player != null:
		player.queue_free()
