extends Node2D

var player1_pos = Vector2.ZERO
var player1_tile_pos = Vector2.ZERO
var player1_tile = null
var player1_in_grass = false
var player2_in_grass = false
var player1_place = 0
var player2_place = 0
var TT1_track_trackers_dict = {1:"+H", 2:"+V",3:"-H",4:"-V",5:"-H",6:"-V"}
var track_trackers_tracks_dict = {"TestTrack1" : TT1_track_trackers_dict}

func _on_GrassArea2D_body_entered(_body: Node) -> void:
	for body in $GrassArea2D.get_overlapping_bodies():
		if body.is_in_group("local_car"):
			if body.name == "Car1" or body.name == str(Network.net_id):
				player1_in_grass = true
			else:
				player2_in_grass = true

func _on_GrassArea2D_body_exited(_body: Node) -> void:
	for body in $GrassArea2D.get_overlapping_bodies():
		if body.is_in_group("local_car"):
			if body.name == "Car1" or body.name == str(Network.net_id):
				player1_in_grass = false
			else:
				player2_in_grass = false

