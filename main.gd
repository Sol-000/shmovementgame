extends Node3D




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



var client = null

func _ready():
	start_client()

func start_client():
	client = ENetMultiplayerPeer.new()
	var result = client.create_client("127.0.0.1", 12345)  # Server IP and port number
	if result != OK:
		print("Failed to connect to server")
		return
	get_tree().set_network_peer(client)
	client.connect("connection_succeeded", self, "_on_connection_succeeded")
	client.connect("connection_failed", self, "_on_connection_failed")
	client.connect("connection_error", self, "_on_connection_error")
	print("Client attempting to connect to server at 127.0.0.1:12345")

func _on_connection_succeeded():
	print("Successfully connected to the server")

func _on_connection_failed():
	print("Failed to connect to the server")

func _on_connection_error():
	print("Connection error")
