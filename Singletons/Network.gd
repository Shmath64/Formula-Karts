extends Node

var ip = "127.0.0.1"
var port = 9999
#var enet_peer = ENetMultiplayerPeer.new()
const MAX_CLIENTS = 8

var net_id = null
var is_host = false
var peer_ids = [] #Peer ids only has the other connected peers ids
var players = []
var splitscreen_players = [] #List of peer ids that are using splitscreen

var players_ordered = false

var player_num_dict = {1:0} #In format {id : player_num}

var num_of_players = 0
var num_of_other_players = 0

func create_server():
	is_host = true
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	net_id = multiplayer.get_unique_id()
	#multiplayer.peer_connected.connect(someoneConnected())
	#peer.create_server(port, MAX_CLIENTS)
	#set_multiplayer_peer(peer)
	
func join_server():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", port)
	multiplayer.multiplayer_peer = peer
	net_id = multiplayer.get_unique_id()
	#get_tree().set_multiplayer_peer(peer)
		
func not_solo(id):
	rpc("update_splitscreen_players", id)

@rpc("any_peer", "call_local") func update_splitscreen_players(id):
	#print("id = %s" % id)
	splitscreen_players.append(id)
	#print("splitscreen player connected")
	#print("%s = splitscreen players" % splitscreen_players)
	
	
func set_ids(): #Run after everyone has joined, This function gets the unique network ID of the current game instance and all other game instances connected
	#Everyone calls this, only the host "order_players"
	peer_ids = multiplayer.get_peers()
	print("multiplayer, get_peers %s", peer_ids)
	#print("peer ids: %s" % peer_ids)
	#print("splitscreen players: " + str(splitscreen_players))
	for peer_id in peer_ids:
		if splitscreen_players.has(peer_id):
			#print("splitscreen player connected")
			pass
	players = peer_ids


func call_peer(node_path, function, data):
	rpc("recive_call", node_path, function, data)
	
@rpc("any_peer") func recive_call(node_path, function, data):
	get_tree().get_root().get_node(node_path).run_server_func(function, data)
	
func order_players():
	var player_num = 1
	if !GameSettings.solo_game:
		player_num_dict[2] = player_num
		player_num += 1
		splitscreen_players.append(1)
	for id in peer_ids:
		player_num_dict[id] = player_num
		player_num += 1
		if splitscreen_players.has(id):
			player_num_dict[id+1] = player_num
			player_num += 1
	players = player_num_dict.keys()
	rpc("get_splitscreen_players", splitscreen_players)
	rpc("get_player_order", player_num_dict)
	players_ordered = true
	
@rpc("any_peer", "call_local") func get_splitscreen_players(_splitscreen_players):
	splitscreen_players = _splitscreen_players
	
@rpc("any_peer", "call_local") func get_player_order(_player_num_dict):
	player_num_dict = _player_num_dict
	players_ordered = true
