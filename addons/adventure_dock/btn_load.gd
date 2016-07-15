#
#-when pressed, attempt loading file in path_selector into main_graph
#--if file doesn't exist, or other error
#---set path_selector text color to red
#--if file exists, clear & load file content to main_graph
#---set path_selector text color to green
#
extends Button

onready var g = get_tree().get_root()

func _ready():
	connect("pressed", self, '_pressed')

func _pressed():
	