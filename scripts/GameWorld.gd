extends Node
#Each Tile is 32x32

var track = load("res://Scenes/Tracks/TestTrack1.tscn")
var car = preload("res://Scenes/Car.tscn")
var red_car = preload("res://Art/Cars/Red Car.png")
var blue_car = preload("res://Art/Cars/Blue Car.png")
var green_car = preload("res://Art/Cars/Green Car.png")
var orange_car = preload("res://Art/Cars/Orange Car.png")
var purple_car = preload("res://Art/Cars/Purple Car.png")
var teal_car = preload("res://Art/Cars/Teal Car.png")
var yellow_car = preload("res://Art/Cars/Yellow Car.png")
var MEG_car = preload("res://Art/Cars/MEG Car.png")
var players_created = false

var car_colors = [red_car, blue_car, green_car, orange_car, purple_car, teal_car, yellow_car]
var starting_positions = [Vector2(0,32), Vector2(0,-32), Vector2(-64,32), Vector2(-64,-32), Vector2(-128,32), Vector2(-128,-32)]

func _ready() -> void:
	print("solo game: %s" % GameSettings.solo_game)
	if GameSettings.offline_game == false:
		Network.set_ids()
		if Network.is_host:
			Network.order_players()
	
	track = track.instantiate()
	track.set_name("track")
	add_child(track)
	
	if GameSettings.offline_game == true:
		if GameSettings.solo_game:
			var car1 = car.instantiate()
			car1.set_name("Car1")
			car1.position = starting_positions[0]
			car1.initialize(0)
			add_child(car1)
		else:
			var car1 = car.instantiate()
			var car2 = car.instantiate()
			car2.local_player_num = 2
			car1.position = starting_positions[0]
			car1.set_name("Car1")
			car2.position = starting_positions[1]
			car2.set_name("Car2")
			car1.initialize(0)
			car2.initialize(0) #0 means it's an offline player
			add_child(car1)
			add_child(car2)
		
func _process(_delta: float) -> void:
	if Network.is_host:
		pass #This is where you'd run commands that should only be done on one computer such as spawning powerups
	if Network.players_ordered and !players_created:
		create_players()
		players_created = true
		
func create_players():
	for id in Network.peer_ids: #Create other cars
		create_player(id)
		if Network.splitscreen_players.has(id):
			create_player(id+1)
	create_player(Network.net_id) #Create this car
	if !GameSettings.solo_game:
		create_player(Network.net_id+1)
	
func create_player(id):
	var p = preload("res://Scenes/Car.tscn").instantiate()
	p.name = str(id)
	p.position = starting_positions[Network.player_num_dict[id]]
	p.change_color(car_colors[Network.player_num_dict[id]])
	p.z_index = 1
	add_child(p)
	p.initialize(id)
