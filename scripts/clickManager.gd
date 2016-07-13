
extends Node

onready var g = get_tree().get_root().get_node('GameManager')

func _ready():
	g.clearMode = 0
	g.charThumbDict['clime'] = preload('res://assets/sample/s_Clime.png')
	g.charThumbDict['finch'] = preload('res://assets/sample/s_Finch.png')
	g.charThumbDict['mertha'] = preload('res://assets/sample/s_Mertha.png')

#--START (link Clickables to here via plug icon)


func _on_SampleClickable_pressed():
	g.dialogue('clime', 'hi guys', 0)
	g.choice(['This is a sample choice', 'You can have many options'], '_choiceCB', self, 0)

func _choiceCB(selected):
	g.dialogue('finch', 'you selected '+ str(selected), 0)
	g.dialogue('finch', 'and now, youll see a photo', 0)
	g.photo('res://assets/sample/samplePhoto.png', false, 0)	