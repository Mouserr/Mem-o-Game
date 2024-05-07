extends Node3D

"metadata/Sprites"
"metadata/GridSize"

@export var GridSize = Vector2i(4, 4)
@export var SpriteSize = Vector2(50, 50)
@export var CardOffset = Vector2(5, 5)
@export var MemoCardScene : PackedScene
@export var Textures = [
	preload("res://Art/button.png"), 
	preload("res://Art/Cereal_Guy.png"), 
	preload("res://Art/fuck-yeah.png"), 
	preload("res://Art/da-ladno.png"), 
	preload("res://Art/smagdzhek.png"),
	preload("res://Art/Trollface.png"), 
	preload("res://Art/безысходность.png"), 
	preload("res://Art/thanks.png")
]
	
var Cards = []
var Values = []
var FlippedCards = []
@onready var MyTimer = $"Timer"

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(GridSize.x):
		for j in range(GridSize.y):
			var sprite = MemoCardScene.instantiate()
			add_child(sprite)
			sprite.position = Vector3(i * SpriteSize.x + CardOffset.x, j * SpriteSize.y + CardOffset.y, 0)
			var index = randi_range(0, Textures.size() - 1);
			sprite.init(Textures[index], self, Cards.size())
			Cards.append(sprite)
			Values.append(index)
			
func OnCardClicked(card: Node3D, index: int):
	if (FlippedCards.has(index)):
		return

	card.Flip()
	FlippedCards.append(index)
	var newValue = Values[index];
	for flippedIndex in FlippedCards:
		if (newValue != Values[flippedIndex]):
			FlipAllBack();
			return
	
	# we flipped correct card
	for otherIndex in range(Values.size()):
		if (Values[otherIndex] == newValue && !FlippedCards.has(otherIndex)):
			return # still have cards to flip
	
	# if we got here it means success and we can start picking card with other value
	FlippedCards.clear()
	TryEndGame()

func TryEndGame():
	for card in Cards:
		if !card.Flipped:
			return
	
	# if all cards are flipped - we can restart the game
	MyTimer.start()

func FlipAllBack():
	for flippedIndex in FlippedCards:
		Cards[flippedIndex].FlipBack()
	
	FlippedCards.clear()


func _on_timer_timeout():
	get_tree().reload_current_scene()
