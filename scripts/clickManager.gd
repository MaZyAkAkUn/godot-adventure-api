
extends Node

onready var g = get_tree().get_root().get_node('GameManager')

func _ready():
	g.char_thumbs['clime'] = preload('res://assets/sample/s_Clime.png')
	g.char_thumbs['finch'] = preload('res://assets/sample/s_Finch.png')
	g.char_thumbs['mertha'] = preload('res://assets/sample/s_Mertha.png')

#--START (link Clickables to here via plug icon)


func _on_SampleClickable_pressed():
	g.dialogue('clime', 'hi guys', 0)
	g.choice(['This is a sample choice', 'You can have many options'], '_choiceCB', self, 0)

func _choiceCB(selected):
	g.dialogue('finch', 'you selected (index): '+ str(selected), 0)
	g.dialogue('finch', 'and now, youll see a photo', 0)
	g.media('sprite', load('res://assets/sample/samplePhoto.png'), 0)
	g.dialogue('finch', 'BUT now, youll hear something!', 0)
	g.media('audio', 's_FortuneDaysCut', 0)
	g.dialogue('finch', 'and nthat ends our little demo!', 0)