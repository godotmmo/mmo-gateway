extends Node

var gateway = ENetMultiplayerPeer.new()
var port = 24598
var max_players = 100
var cert = load("res://certificate/X509_Certificate.crt")
var key = load("res://certificate/X509_Key.key")


func _ready():
	StartServer()


func _process(_delta):
	if !multiplayer.has_multiplayer_peer():
		return;
	multiplayer.poll()


func StartServer():
	# Creates Server for the gateway
	if (gateway.create_server(port, max_players)):
		print("Error while starting gateway server")
		return
	
	# dtls setup
	gateway.host.dtls_server_setup(key, cert)
	
	# Creates a new default Multiplayer instance for the scene tree
	get_tree().set_multiplayer(MultiplayerAPI.create_default_interface(), get_path())
	
	# Sets the server we created as a peer for the newly created Multiplayer instance
	multiplayer.set_multiplayer_peer(gateway)
	print("Gateway server started")
	
	if (gateway.peer_connected.connect(self._Peer_Connected) || gateway.peer_disconnected.connect(self._Peer_Disconnected)):
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


@rpc(call_remote)
func ReturnLoginRequest(result, player_id, token):
	rpc_id(player_id, "ReturnLoginRequest", result, token)
	await get_tree().create_timer(1).timeout
	gateway.disconnect_peer(player_id)


@rpc
func RequestCreateAccount():
	# Used for rpc checksum
	pass


@rpc(any_peer)
func CreateAccountRequest(username, password):
	var player_id = multiplayer.get_remote_sender_id()
	var valid_request = true
	if username == "":
		valid_request = false
	if password == "":
		valid_request = false
	if password.length() <= 6:
		valid_request = false
	
	if valid_request == false:
		ReturnCreateAccountRequest(valid_request, player_id, 1)
	else:
		Authentication.CreateAccount(username.to_lower(), password, player_id)


@rpc(call_local)
func ReturnCreateAccountRequest(result, player_id, message):
	rpc_id(player_id, "ReturnCreateAccountRequest", result, message)
	# 1 = failed to create, 2 = existing username, 3 = welcome
	await get_tree().create_timer(1).timeout
	gateway.disconnect_peer(player_id)
