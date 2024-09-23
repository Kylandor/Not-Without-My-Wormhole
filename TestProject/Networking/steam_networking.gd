extends Node

var peer :SteamMultiplayerPeer 

const MAX_PLAYERS = 4

func _ready():
	peer = SteamMultiplayerPeer.new()
	
	OS.set_environment("SteamAppId", str(480))
	OS.set_environment("SteamGameId", str(480)) 
	
	Steam.steamInitEx()
	pass
	
func _process(delta):
	Steam.run_callbacks()

func createLobby():
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, MAX_PLAYERS)
	
func steamHost():
	peer.create_host(0)
	multiplayer.multiplayer_peer = peer
	
func steamJoin():
	peer.create_client(ConnectionOptions.getIP(), 0)
