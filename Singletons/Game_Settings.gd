extends Node

var offline_game = false
var solo_game = true
var map_selection = "TestTrack1"
var game_on = false
var player1_name
var player2_name
var player_pos_dict = {} #Format ID: Vector2(pos)
var player_places

func determine_places():
	pass

func get_sector(pos):
	#To convert tilemap cord to global: *32 - 16
	var sector
	var x = pos.x
	var y = pos.y
	if map_selection == "TestTrack1":
		if y <= 112:
			sector = 1
		elif x >= 1200:
			sector = 2
		elif x < 1200 and x >= 656 and y > 1616:
			sector = 3
		elif x >= 368 and y >= 1040:
			sector = 4
		elif x <= 720 and x >= -144 and y >= 720:
			sector = 5
		elif x <= 0:
			sector = 6
	return sector
			
func _process(_delta: float) -> void:
		if Network.is_host and GameSettings.game_on:
			determine_places()
		
