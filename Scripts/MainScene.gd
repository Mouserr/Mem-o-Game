extends Node3D

@onready var Grid = $Grid
@onready var Camera = $Camera3D
@onready var TimeLabel = $Timer/Time
@onready var CountLabel = $Counter/Count
@onready var SuccessPlayer = $AnimationPlayer


@onready var Player = get_node("/root/Player")
var CurrentTime = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var count = Grid.Build()
	FocusCameraOnNode(Camera, Grid,.4)
	CountLabel.text = "%d" % count


func FocusCameraOnNode(camera: Camera3D, node: Node3D, margin = 1.1) -> void:
	var fov = camera.fov
	var max_extent =  node.GetLongestAxisSize()
	var min_distance = (max_extent * margin) / sin(deg_to_rad(fov / 2.0))

	camera.position = node.GetCenter() + Vector3(0, 0, min_distance)
		
func _process(delta):
	if (!Grid.IsEnded):
		CurrentTime = CurrentTime + delta
		TimeLabel.text = TimeConvert(CurrentTime)
	
func _physics_process(delta):
	if (Input.is_action_just_pressed("NextLevel")):
		Player.StartNextLevel()
	if (Input.is_action_just_pressed("PrevLevel")):
		Player.StartPrevLevel()


func TimeConvert(time):
	var time_in_min = floori(time/60)
	var minutes = (time_in_min)%60
		
	#returns a string with the format "MM:S.MS"
	return "%02d:%02.2f" % [minutes, time - time_in_min]


func _on_grid_success():
	pass
