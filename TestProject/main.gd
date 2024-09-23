extends Node3D

const Stage = preload("res://Levels/world.tscn")
const Player = preload("res://Player/player_instance.tscn")

var enet_peer = ENetMultiplayerPeer.new()
const PORT = 9159

const PACKET_READ_LIMIT = 32

var steam_id: int = 0
var steam_username: String = ""

var lobby_id = 0

var peer = SteamMultiplayerPeer.new()

var lobby_members_max = 4


func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
		
# Called when the node enters the scene tree for the first time.
func _ready():
	
	peer = SteamMultiplayerPeer.new()
	
	OS.set_environment("SteamAppId", str(480))
	OS.set_environment("SteamGameId", str(480)) 
	
	Steam.steamInitEx(true, 480)

	
	Steam.lobby_joined.connect(
		func (new_lobby_id: int, _permissions: int, _locked: bool, response: int):
		if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
			lobby_id = new_lobby_id
			print("the id")
			print(lobby_id)
			var id = Steam.getLobbyOwner(new_lobby_id)
			if id != Steam.getSteamID():
				connect_steam_socket(id)
				
		else:
			# Get the failure reason
			var FAIL_REASON: String
			match response:
				Steam.CHAT_ROOM_ENTER_RESPONSE_DOESNT_EXIST:
					FAIL_REASON = "This lobby no longer exists."
				Steam.CHAT_ROOM_ENTER_RESPONSE_NOT_ALLOWED:
					FAIL_REASON = "You don't have permission to join this lobby."
				Steam.CHAT_ROOM_ENTER_RESPONSE_FULL:
					FAIL_REASON = "The lobby is now full."
				Steam.CHAT_ROOM_ENTER_RESPONSE_ERROR:
					FAIL_REASON = "Uh... something unexpected happened!"
				Steam.CHAT_ROOM_ENTER_RESPONSE_BANNED:
					FAIL_REASON = "You are banned from this lobby."
				Steam.CHAT_ROOM_ENTER_RESPONSE_LIMITED:
					FAIL_REASON = "You cannot join due to having a limited account."
				Steam.CHAT_ROOM_ENTER_RESPONSE_CLAN_DISABLED:
					FAIL_REASON = "This lobby is locked or disabled."
				Steam.CHAT_ROOM_ENTER_RESPONSE_COMMUNITY_BAN:
					FAIL_REASON = "This lobby is community locked."
				Steam.CHAT_ROOM_ENTER_RESPONSE_MEMBER_BLOCKED_YOU:
					FAIL_REASON = "A user in the lobby has blocked you from joining."
				Steam.CHAT_ROOM_ENTER_RESPONSE_YOU_BLOCKED_MEMBER:
					FAIL_REASON = "A user you have blocked is in the lobby."
			print("me errord")
			print(FAIL_REASON)
	)
	Steam.lobby_created.connect(
		func(status: int, new_lobby_id: int):
			if status == 1:
				print("made lobby")
				var current_clipboard = DisplayServer.clipboard_get()
				DisplayServer.clipboard_set(str(new_lobby_id))
				#lobby_id = new_lobby_id
				Steam.setLobbyData(new_lobby_id, "name", 
					str(Steam.getPersonaName(), "'s Spectabulous Test Server"))
				create_steam_socket()
			else:
				print("Error on create lobby!")
	)

	if ConnectionOptions.getHost():
		steamHost()
	else:
		steamJoin()

	print(Steam.getSteamID())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Steam.steamInitEx()
	pass

func basic_host():
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
		
		
func steamHost():
	if lobby_id == 0:
		Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, lobby_members_max)
	
func steamJoin():
	var lobby = int(ConnectionOptions.getIP())
	print("Joining Lobby: " + str(lobby))
	Steam.joinLobby(lobby)
	connect_steam_socket(Steam.getLobbyOwner(lobby))
	
func _on_lobby_created(connect: int, this_lobby_id: int) -> void:
	if connect == 1:
		# Set the lobby ID
		lobby_id = this_lobby_id
		print("Created a lobby: %s" % lobby_id)

		# Set this lobby as joinable, just in case, though this should be done by default
		Steam.setLobbyJoinable(lobby_id, true)

		# Set some lobby data
		Steam.setLobbyData(lobby_id, "name", "Kylandor' Lobby")
		Steam.setLobbyData(lobby_id, "mode", "GodotSteam test")

		var set_relay: bool = Steam.allowP2PPacketRelay(true)
		print("Allowing Steam to be relay backup: %s" % set_relay)
		
#region Steam Peer Management
func create_steam_socket():
	print("lelelele")
	print(peer.create_host(0))
	multiplayer.set_multiplayer_peer(peer)
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(delete_player)
	spawn_level()
	add_player(multiplayer.get_unique_id())

func connect_steam_socket(steam_id):
	print("the id: " + str(steam_id))
	print(peer.create_client(steam_id, 0))
	print("me here")
	multiplayer.set_multiplayer_peer(peer)
		
