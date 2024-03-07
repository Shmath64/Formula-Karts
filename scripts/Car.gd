extends CharacterBody2D

var is_master = false
var spawn_point = Vector2.ZERO
var speed = 0
var max_driving_speed = 400
var current_max_speed = max_driving_speed
var max_to_grass_speed_ratio = 2.5
var max_grass_speed = max_driving_speed / max_to_grass_speed_ratio
var max_reverse_speed = -100
var rotation_speed = 200
var rate_of_deceleration = 350
var rate_of_acceleration = 200
var turning_input = 0
var braking_input = 0
var parking_braked = false
var _velocity = Vector2.ZERO
@export var local_player_num = 1 #local_player_num 1: player1, 2: player2
var splitscreen_id = 0
var lap = 1
var approaching_lap = false
var turn_amount = 0
var wheel_turn_speed = 5
var sector
var boosting_input = false
var is_boosting = false
var boost_fuel = 50
var boost_drain_rate = 25
var boost_strength_speed = 200
var boost_strength_acceleration = 100
var max_turn_while_boosting = 0.5
var crashed_position

var meg_color = preload("res://Art/Cars/MEG Car.png")

func initialize(id): #local_player_num is NOT being set to "2" for the 
	name = str(id)
	print("name: " + name + ", id: " + str(id) + ", local_player_num: " + str(local_player_num))
	if id == 0:
		if local_player_num == 1:
			name = str("Car1")
			$CarHudNodes/NameNode/NameLabel.text = GameSettings.player1_name
		else:
			name = str("Car2")
			$CarHudNodes/NameNode/NameLabel.text = GameSettings.player2_name
	#print("id = %s" % id)
	#print("Net_id = %s" % Network.net_id)
	#if !GameSettings.offline_game:
		#splitscreen_id = Network.net_id + 1
	if id == Network.net_id:
		is_master = true
		$CarHudNodes/NameNode/NameLabel.text = GameSettings.player1_name
		rpc("set_name_tag",GameSettings.player1_name)
		
	if !GameSettings.offline_game:
		splitscreen_id = Network.net_id + 1
		if id == splitscreen_id:
			print("RUN HERE")
			$CarHudNodes/NameNode/NameLabel.text = GameSettings.player2_name
			rpc("set_name_tag",GameSettings.player2_name)
			is_master = true
			local_player_num = 2
	print(Network.player_num_dict)

func _ready() -> void:
	if GameSettings.offline_game:
		is_master = true
		if local_player_num == 2:
			$Sprite2D.texture = load("res://Art/Cars/Blue Car.png")
	if (GameSettings.player1_name == "MEG" and local_player_num == 1) or (GameSettings.player2_name == "MEG" and local_player_num == 2) and is_master :
		change_color(meg_color)
		max_driving_speed += 100

func _process(delta: float) -> void:
	if is_master: 
		get_inputs()
		check_grass(delta)
		_velocity = Vector2(speed,0).rotated(rotation)
		set_velocity(_velocity)
		move_and_slide()
		_velocity = _velocity
		if GameSettings.offline_game == false: #If playing online, update this car's info on others' game instances
			#rpc_unreliable("update_position", position) <- Deprecated format
			update_position.rpc(position)
			update_rotation.rpc(rotation)
			update_braking_input.rpc(braking_input)
			#rpc_unreliable("update_turn_input", turning_input)
			update_turn_input.rpc(turning_input)
			#rpc_unreliable("update_boosting_input", boosting_input)
			update_boosting_input.rpc(boosting_input)
			#rpc_unreliable("update_boost_fuel", boost_fuel)
			update_boost_fuel.rpc(boost_fuel)
			
	turn(delta)
	gas_and_brake(delta)
	check_obstacle()
	parking_brake()
	car_hud()
	check_lap(position)
	GameSettings.player_pos_dict[name] = position

@rpc("any_peer") func update_position(pos):
	position = pos
@rpc("any_peer") func update_rotation(rot):
	rotation = rot
@rpc("any_peer") func update_braking_input(_braking_input):
	braking_input = _braking_input
@rpc("any_peer") func update_turn_input(_turning_input):
	turning_input = _turning_input
@rpc("any_peer") func update_boosting_input(_boosting_input):
	boosting_input = _boosting_input
@rpc("any_peer") func update_boost_fuel(_boost_fuel):
	boost_fuel = _boost_fuel
@rpc("any_peer") func set_name_tag(_name):
	$CarHudNodes/NameNode/NameLabel.text = _name
	
func get_inputs():
	if local_player_num == 1:
		turning_input = -int(Input.get_action_strength("left_1")) + int(Input.get_action_strength("right_1"))
		braking_input = Input.get_action_strength("brake_1")
		boosting_input = Input.is_action_pressed("boost_1")
	elif local_player_num == 2:
		turning_input = -int(Input.get_action_strength("left_2")) + int(Input.get_action_strength("right_2"))
		braking_input = Input.get_action_strength("brake_2")
		boosting_input = Input.is_action_pressed("boost_2")
	if local_player_num == 1 and Input.is_action_just_pressed("parking_break1") or local_player_num == 2 and Input.is_action_just_pressed("parking_brake2"):
		if parking_braked:
			parking_braked = false
		else:
			parking_braked = true

func turn(delta):
	if turning_input > max_turn_while_boosting and is_boosting:
		turning_input = max_turn_while_boosting
	if turning_input > 0:
		if turn_amount < turning_input:
			turn_amount += wheel_turn_speed * delta
		if turn_amount > turning_input:
			turn_amount = turning_input
	elif turning_input < 0:
		if turn_amount > turning_input:
			turn_amount -= wheel_turn_speed * delta
		if turn_amount < turning_input:
			turn_amount = turning_input
	else:
		if turn_amount > 0:
			turn_amount -= wheel_turn_speed * delta * 2
			if turn_amount< 0:
				turn_amount = 0
		if turn_amount < 0:
			turn_amount += wheel_turn_speed * delta * 2
			if turn_amount > 0:
					turn_amount = 0
	rotation_degrees += rotation_speed * turn_amount * delta

func gas_and_brake(delta):
	if boost_fuel > 100:
		boost_fuel = 100
	if boosting_input and boost_fuel > 0:
		is_boosting = true
		boost_fuel -= boost_drain_rate * delta
	else:
		is_boosting = false
	if braking_input > 0:
		is_boosting = false
		var backwards = Vector2(-1,0).rotated(rotation)
		set_velocity(backwards)
		#move_and_slide()
		backwards = _velocity #Prevents the glitch where the player can't reverse while pressed up against a wall
		if speed > 0:
			speed -= rate_of_deceleration * braking_input * delta
		else:
			speed -= rate_of_deceleration * braking_input * delta / 2
		if speed < max_reverse_speed:
			speed = max_reverse_speed
	else:
		if is_boosting:
			current_max_speed = max_driving_speed + boost_strength_speed
			speed += (rate_of_acceleration + boost_strength_acceleration) * delta
		else:
			speed += rate_of_acceleration * delta
			current_max_speed = max_driving_speed
	if speed > current_max_speed:
		speed -= rate_of_deceleration * delta

func parking_brake():
	if parking_braked:
		speed = 0

func check_obstacle():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.collider.is_in_group("walls"):
			if position != crashed_position:
				#$Sounds/TireCrash.playing = true
				pass
			speed = 0
			crashed_position = position

func check_grass(delta):
	if get_parent().get_node("track").player1_in_grass and local_player_num == 1:
		if !is_boosting:
			slow_car(delta)
	elif get_parent().get_node("track").player2_in_grass and local_player_num == 2:
		if !is_boosting:
			slow_car(delta)

func slow_car(delta):
	if speed > max_grass_speed:
		speed -= rate_of_deceleration * delta
	
func change_color(color):
	$Sprite2D.texture = color

func car_hud():
	$CarHudNodes/NameNode.global_position = Vector2(global_position.x, global_position.y-30)
	$CarHudNodes/LapNode.global_position = Vector2(global_position.x, global_position.y+25)
	$CarHudNodes/LapNode/LapLabel.text = str(lap)
	$CarHudNodes.global_rotation = 0
	$BoostNode.global_rotation = 0
	$BoostNode/BoostProgress.value = boost_fuel
	$BoostPartcles.global_rotation = 0
	
func check_lap(pos):
	if GameSettings.get_sector(pos) == 5:
		approaching_lap = true
	if approaching_lap and position.x > 64 and position.y < 200:
		approaching_lap = false
		boost_fuel += 75
		lap += 1
	
