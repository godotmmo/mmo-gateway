extends Node

var gateway: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var port: int = 24598
var max_players: int = 100
var cert = load("res://certificate/X509_Certificate.crt")
var key = load("res://certificate/X509_Key.key")


func _ready() -> void:
	StartServer()


func _process(_delta: float) -> void:
	if !multiplayer.has_multiplayer_peer():
		return;
	multiplayer.poll()


func StartServer() -> void:
	# Creates Server for the gateway
	gateway.create_server(port, max_players)
	
	# dtls setup
	# var server_tls_options = TLSOptions.server(cert, key)
	# gateway.host.dtls_server_setup(server_tls_options)
	
	# Creates a new default Multiplayer instance for the scene tree
	get_tree().set_multiplayer(MultiplayerAPI.create_default_interface(), get_path())
	
	# Sets the server we created as a peer for the newly created Multiplayer instance
	multiplayer.set_multiplayer_peer(gateway)
	print("Gateway server started")
	
	gateway.peer_connected.connect(self._Peer_Connected)
	gateway.peer_disconnected.connect(self._Peer_Disconnected)


func _Peer_Connected(player_id: int) -> void:
	print("User " + str(player_id) + " Connected")


func _Peer_Disconnected(player_id: int) -> void:
	print("User " + str(player_id) + " Disconnected")


@rpc("any_peer")
func LoginRequest(username: String, password: String) -> void:
	print("Login request received")
	var player_id: int = multiplayer.get_remote_sender_id()
	print("Player ID: " + str(player_id))
	Authentication.AuthenticatePlayer(username, password, player_id)


@rpc("call_remote")
func ReturnLoginRequest(result: bool, player_id: int, token: String) -> void:
	rpc_id(player_id, "ReturnLoginRequest", result, token)
	await get_tree().create_timer(3).timeout
	gateway.disconnect_peer(player_id)


@rpc("any_peer")
func CreateAccountRequest(username: String, password: String) -> void:
	var player_id: int = multiplayer.get_remote_sender_id()
	var valid_request: bool = true
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


@rpc("call_local")
func ReturnCreateAccountRequest(result: bool, player_id: int, message: int) -> void:
	rpc_id(player_id, "ReturnCreateAccountRequest", result, message)
	# 1 = failed to create, 2 = existing username, 3 = welcome
	await get_tree().create_timer(1).timeout
	gateway.disconnect_peer(player_id)


###################################################################################################
#							All functions below are used for									  #
#								rpc checksums													  #
###################################################################################################

@rpc
func RequestCreateAccount():
	# Used for rpc checksum
	pass
