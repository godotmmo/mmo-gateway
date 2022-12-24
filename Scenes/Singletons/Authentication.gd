extends Node

var authentication_client = ENetMultiplayerPeer.new()
var ip = "that-genetics.at.ply.gg"
var port = 44125


func _ready():
	ConnectToServer()


func ConnectToServer():
	authentication_client.create_client(ip, port)
	multiplayer.set_multiplayer_peer(authentication_client)
	
	authentication_client.peer_disconnected.connect(_Connection_Failed)
	authentication_client.peer_connected.connect(_Connection_Succeeded)


func _Connection_Succeeded(gateway_id):
	print(str(gateway_id) + "Sucecssfully connected to authentication server")


func _Connection_Failed(gateway_id):
	print(str(gateway_id) + "Failed to connect to authentication server")


@rpc(call_local)
func AuthenticatePlayer(username, password, player_id):
	print("Sending out authentication request")
	rpc_id(1, "AuthenticatePlayer", username, password, player_id)


@rpc
func AuthenticationResults(result, player_id, token):
	print("Results received and replying to player login request")
	Gateway.ReturnLoginRequest(result, player_id, token)


@rpc(call_local)
func CreateAccount(username, password, player_id):
	print("Sending out create account request")
	rpc_id(1, "CreateAccount", username, password, player_id)


@rpc(call_remote)
func CreateAccountResults(result, player_id, message):
	print("Results received and replying to player create account request")
	Gateway.ReturnCreateAccountRequest(result, player_id, message)
