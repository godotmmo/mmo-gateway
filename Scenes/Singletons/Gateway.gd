extends Node

var network = ENetMultiplayerPeer.new()
var port = 24598
var max_players = 100


func _ready():
	StartServer()


func _process(delta):
	if !multiplayer.has_multiplayer_peer():
		return;
	multiplayer.poll()


func StartServer():
	if (network.create_server(port, max_players)):
		print("Error while starting gateway server")
		return
	
	get_tree().set_multiplayer(MultiplayerAPI.create_default_interface(), get_path())
	multiplayer.set_multiplayer_peer(network)
	print("Gateway server started")
	
	if (network.peer_connected.connect(self._Peer_Connected) || network.peer_disconnected.connect(self._Peer_Disconnected)):
		print("Failed to authenticate")
		return


func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected")


func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected")


@rpc(any_peer)
func LoginRequest(username, password):
	print("Login request received")
	var player_id = multiplayer.get_remote_sender_id()
	print("Player ID: " + str(player_id))
	Authentication.AuthenticatePlayer(username, password, player_id)


@rpc(call_local)
func ReturnLoginRequest(result, player_id):
	rpc_id(player_id, "ReturnLoginRequest", result)
	await get_tree().create_timer(1).timeout
	network.disconnect_peer(player_id)
