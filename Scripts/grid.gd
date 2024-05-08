extends Node3D

"metadata/Sprites"
"metadata/GridSize"

@export var SpriteSize = Vector2(6.5, 6.5)
@export var MemoCardScene : PackedScene
@export var Textures = [
]
	
var Cards = []
var Values = []
var FlippedCards = []

var IsEnded : bool

@onready var MyTimer = $"Timer"

@onready var Player = get_node("/root/Player")

signal Success()


func GetRandomElements(neededCount: int, sourceArray: Array) -> Array:
	var leftSize = Textures.size()
	var Result = []
	#print("Getting random elements ", neededCount, " from ", leftSize)
	for i in range(Textures.size()):
		if (randf_range(0, leftSize) <= neededCount):
			neededCount = neededCount - 1
			Result.append(i)
			
		leftSize = leftSize - 1
		
	#print("Result: ", Result)
		
	return Result
	
func GetRandomElement(probabilities: Array) -> int:
	if (probabilities.size() == 1):
		return 0
	
	var sum = 0.
	for prob in probabilities:
		sum += prob
		
	var random = randf_range(.0, sum)

	sum = 0.
	
	for i in range(probabilities.size()):
		sum += max(0, probabilities[i])
		if (random <= sum):
			return i

	return probabilities.size() - 1

# Called when the node enters the scene tree for the first time.
func Build() -> int:
	var cardsNum = Player.CurrentGridSize.x * Player.CurrentGridSize.y;
	var texturesSize = min(randi_range(cardsNum / 4, cardsNum / 2), Textures.size())
	#print("Start textures size: ", texturesSize)
	var usingTextures = GetRandomElements(texturesSize, Textures)
	var delta = max(0., (Player.CurrentGridSize.x - 4) * 1/12.)
	SpriteSize = SpriteSize + Vector2(delta, delta)
	var probabilities = []
	for i in range(texturesSize):
		probabilities.append(cardsNum / texturesSize)
	
	for i in range(Player.CurrentGridSize.x):
		for j in range(Player.CurrentGridSize.y):
			var index = GetRandomElement(probabilities)
			probabilities[index] = probabilities[index] - 1
			var textureIndex = usingTextures[index]
			Values.append(textureIndex)
		
	# find not paired textures
	var notPairedTextures = []
	for i in range(texturesSize):
		if (probabilities[i] >= cardsNum / texturesSize):
			notPairedTextures.append(usingTextures[i])
	
	#print("Values: ", Values)
	#print("Not Paired: ", notPairedTextures.size(), " = ", notPairedTextures)
	# ensure we don't have non-paired cards
	if (notPairedTextures.size() > 0):
		
		if (notPairedTextures.size() == 1):
			var textureForChange = usingTextures.pick_random()
			while textureForChange != notPairedTextures[0]:
				textureForChange = usingTextures.pick_random()
			
			for i in range(Values.size()):
				if (notPairedTextures.has(Values[i])):
					Values[i] = textureForChange
					
			texturesSize -= 1
		else:
			var notPairedIndex = 0
			var currentTextureCount = 0
			for i in range(Values.size()):
				if (notPairedTextures.has(Values[i])):
					#print("Changing ", Values[i], " to ", notPairedTextures[notPairedIndex], " on index ", i)
					Values[i] = notPairedTextures[notPairedIndex]
					currentTextureCount = currentTextureCount + 1;
					if (currentTextureCount > notPairedTextures.size()/2):
						currentTextureCount = 0;
						notPairedIndex += 1;
					
			texturesSize -= notPairedTextures.size() - notPairedIndex
		
	
	for i in range(Values.size()):
		var textureIndex = Values[i]
		var sprite = MemoCardScene.instantiate()
		add_child(sprite)
		var x = floori(i / Player.CurrentGridSize.y)
		var y = i % Player.CurrentGridSize.y
		sprite.position = Vector3(x * SpriteSize.x, y * SpriteSize.y, 0)
		
		sprite.init(Textures[textureIndex], self, Cards.size())
		Cards.append(sprite)
		
	return texturesSize
			
func OnCardClicked(card: Node3D, index: int):
	if (FlippedCards.has(index)):
		return

	card.Flip()
	FlippedCards.append(index)
	var newValue = Values[index]
	for flippedIndex in FlippedCards:
		if (newValue != Values[flippedIndex]):
			FlipAllBack()
			return
	
	# we flipped correct card
	for otherIndex in range(Values.size()):
		if (Values[otherIndex] == newValue && !FlippedCards.has(otherIndex)):
			return # still have cards to flip
	
	# if we got here it means success and we can start picking card with other value
	Success.emit()
	for flippedIndex in FlippedCards:
		Cards[flippedIndex].PlaySuccess()
	FlippedCards.clear()
	TryEndGame()

func TryEndGame():
	for card in Cards:
		if !card.Flipped:
			return
	
	# if all cards are flipped - we can restart the game
	IsEnded = true
	MyTimer.start()

func FlipAllBack():
	for flippedIndex in FlippedCards:
		Cards[flippedIndex].FlipBack()
	
	FlippedCards.clear()

func GetLongestAxisSize():
	return max(Player.CurrentGridSize.x * SpriteSize.x, Player.CurrentGridSize.y * SpriteSize.y)
	
func GetCenter():
	return Vector3(position.x + (Player.CurrentGridSize.x - 1) * SpriteSize.x / 2, position.y +  (Player.CurrentGridSize.y - 1) * SpriteSize.y / 2, position.z)

func _on_timer_timeout():
	Player.StartNextLevel()
