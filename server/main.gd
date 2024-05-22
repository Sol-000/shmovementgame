extends Node3D

var server = null
# Called when the node enters the scene tree for the first time.
func _ready():
	server = ENetMultiplayerPeer.new()
	server.create_server(12345)
	get_tree().set_network_peer(server)
	server.connect("peer_connected", self, "_on_peer_connected")
	server.connect("peer_disconnected", self, "_on_peer_disconnected")
	print("Server started on port 12345")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


	

func _on_peer_connected(id):
	print("Peer connected: %d" % id)

func _on_peer_disconnected(id):
	print("Peer disconnected: %d" % id)
