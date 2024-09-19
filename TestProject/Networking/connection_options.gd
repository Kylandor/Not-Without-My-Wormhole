extends Node

#THIS IS AN AUTOLOAD SCRIPT, MEANING IT IS SET EVERYWHERE, SPECIFICED IN PROEJCT -> PROJECT SETTINGS -> AUTOLOAD

var isHost:bool = false

var connectionIP:String = "localhost"

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func setHost(host:bool):
	isHost = host
	
func getHost():
	return isHost
	
func setIP(ip:String):
	connectionIP = ip
	
func getIP():
	return connectionIP
	
