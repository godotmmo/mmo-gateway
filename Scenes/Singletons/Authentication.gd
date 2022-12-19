extends Node

var network = ENetMultiplayerPeer.new()
var ip = "that-genetics.at.ply.gg"
var port = 44125


func _ready():
	ConnectToServer()


func ConnectToServer():
	network.create_client(ip, port)
	multiplayer.set_multiplayer_peer(network)
	
	network.peer_disconnected.connect(_Connection_Failed)
	network.peer_connected.connect(_Connection_Succeeded)


func _Connection_Succeeded(gateway_id):
	print(str(gateway_id) + "Sucecssfully connected to authentication server")


func _Connection_Failed(gateway_id):
	print(str(gateway_id) + "Failed to connect to authentication server")


@rpc
func AuthenticatePlayer(username, password, player_id):
	print("Sending out authentication request")
	rpc_id(1, "AuthenticatePlayer", username, password, player_id)


@rpc(call_local)
func AuthenticationResults(result, player_id):
	print("Results received and replying to player login request")
	Gateway.ReturnLoginRequest(result, player_id)
