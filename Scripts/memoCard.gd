extends Node3D

@onready var FrontSprite = $Card/Front
@onready var AnimPlayer = $AnimationPlayer
@onready var SuccessPlayer = $SuccessPlayer

var Grid
var Index : int
var Flipped : bool

func init(texture: Texture2D, grid: Node3D, index: int):
	FrontSprite.texture = texture
	Grid = grid
	Index = index

func Flip():
	if !Flipped:
		AnimPlayer.play("Flip")
		Flipped = true
	
	
func FlipBack():
	if Flipped:
		AnimPlayer.play("FlipBack")
		Flipped = false
		
func PlaySuccess():
	SuccessPlayer.play("Success")

func _on_area_3d_input_event(camera, event, position, normal, shape_idx):
	if !Flipped:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
				Grid.OnCardClicked(self, Index)
