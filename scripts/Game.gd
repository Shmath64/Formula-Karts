extends Node

@onready var viewport1 = $Viewports/ViewportContainer1/Viewport1
@onready var viewport2 = $Viewports/ViewportContainer2/Viewport2
@onready var camera1 = $Viewports/ViewportContainer1/Viewport1/Camera2D1
@onready var camera2 = $Viewports/ViewportContainer2/Viewport2/Camera2D2
@onready var world = $Viewports/ViewportContainer1/Viewport1/GameWorld

		
		
func _ready() -> void:
	if GameSettings.solo_game:
			$Viewports/ViewportContainer2.visible = false
			$Viewports/ViewportContainer1/Line2D.visible = false
	else:
		viewport2.world_2d = viewport1.world_2d
	if GameSettings.offline_game:
		if !GameSettings.solo_game:
			camera2.target = world.get_node("Car2")
		camera1.target = world.get_node("Car1")
	else:
		if Network.is_host:
			Network.order_players()

func _process(_delta: float) -> void:
	if GameSettings.offline_game == false:
		camera1.target = world.get_node(str(Network.net_id))
		if !GameSettings.solo_game:
			camera2.target = world.get_node(str(Network.net_id+1))
	else:
		camera1.target = world.get_node("Car1")
		if !GameSettings.solo_game:
			camera2.target = world.get_node("Car2")


