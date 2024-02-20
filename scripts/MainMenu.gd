extends Node

var is_client = false

func _on_Host_button_down() -> void:
	$Host.disabled = true
	$Join.disabled = true
	$Status.text = "Hosting Server"
	$Start.disabled = false
	#Network.own_name = $NameEdit.text
	set_names($NameEdit.text,$NameEdit2.text)
	Network.create_server()
	Network.net_id = get_tree().get_unique_id()
	print("host")


func _on_Join_button_down() -> void:
	is_client = true
	$Host.disabled = true
	$Join.disabled = true
	$Status.text = "joining server..."
	#Network.own_name = $NameEdit.text
	set_names($NameEdit.text,$NameEdit2.text)
	Network.join_server()
	print("join")

func _ready():
	get_tree().connect("connected_to_server", Callable(self, "connected"))
		
func connected():
	Network.net_id = get_tree().get_unique_id()
	rpc("player_connected", GameSettings.solo_game, Network.net_id)
	$Status.text = "Connected to server"
	
@rpc("any_peer") func player_connected(is_solo,id):
	if Network.is_host:
		Network.num_of_players += 1
		if !is_solo:
			Network.not_solo(id)
			Network.num_of_players += 1
		$Status.text = "%s player(s) connected" % Network.num_of_players

@rpc("any_peer") func begin_game():
	GameSettings.game_on = true
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")

func _on_Start_button_down() -> void:
	rpc("begin_game")
	begin_game()

func _on_SplitscreenCheckBox_button_down() -> void:
	if GameSettings.solo_game == true: 
		GameSettings.solo_game = false
		$NameEdit2.editable = true
	else:
		$NameEdit2.editable = false
		GameSettings.solo_game = true

func _on_OfflineGameButton_button_down() -> void:
	GameSettings.offline_game = true
	set_names($NameEdit.text,$NameEdit2.text)
	begin_game()
	
func set_names(p1_name,p2_name):
	GameSettings.player1_name = p1_name
	GameSettings.player2_name = p2_name
