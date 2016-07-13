
extends Node2D
#---PUBLIC CONFIG VARIABLES
var clearMode = 0 #0=clear dialogue after choice/photo, 1=leave last dialogue instead
var charThumbDict = {} #{"name": "thumb_preloaded"} #character thumbnail database

#---PRIVATE VARIABLES
var _viewDB = [] #LIFO structure that holds dialogues, choices, & photos
var _contentType = '' #determine type in _viewDB switch @ _process
var _canProgress = true #used to manage progression with _viewShield

var _currentCb = ''
var _currentCaller = ''

onready var _dlText = get_node('DialogueSys/DialogueText')
onready var _dlThumb = get_node('DialogueSys/DialogueThumb')
onready var _chBtnArr = get_node('ChoiceSys/ScrollContainer/VButtonArray')
onready var _phSprite = get_node('PhotoSys/Sprite')
onready var _viewShield = get_node('ViewShield')

#---PUBLIC API
func dialogue(charNameStr, textStr, posBF):
	_viewDB.push_front({"type": "dialogue", "content": textStr, "pos": posBF, "name": charNameStr})

func choice(choiceTextArr, callback, caller, posBF): 
	_viewDB.push_front({"type": "choice", "content": choiceTextArr, "pos": posBF}) 
	_currentCb = callback 
	_currentCaller = caller

func photo(pathStr, preloadedBool, posBF):
	_viewDB.push_front({"type": "photo", "preloaded": preloadedBool, "content": pathStr, "pos": posBF})


#---VIEW SHIELD IMPLEMENTATION (Should be on whenever there's dialogue/choice/photo)
func _on_ViewShield_pressed():
	if(_chBtnArr.get_parent().is_hidden()): #not in choice mode, can _progress
		_progress()

func _on_choice_btnSelected(btnId):
	_currentCaller.call(_currentCb, btnId)
	_progress()

func _progress(): #(Let dialogue _progress, photo disappear, or choice=-1)
	_clear()
	if(_viewDB.size() == 0): #if no more to _progress through, hide shield & clear (mode 0)
		_viewShield.set_hidden(true)
		_dlText.clear()
		_dlThumb.set_texture(null)
		_dlText.set_hidden(true)
		_dlThumb.set_hidden(true)
	if(!_chBtnArr.get_parent().is_hidden()): #also hide any choices (if any)
		_chBtnArr.get_parent().set_hidden(true)
	_canProgress = true

func _clear():
	if(clearMode == 0):
		_dlText.clear()
		_dlThumb.set_texture(null)
		_dlText.set_hidden(true)
		_dlThumb.set_hidden(true)
	_chBtnArr.clear()
	_phSprite.set_hidden(true)


#---SWITCH TO DISPLAY _viewDB CONTENTS
func _ready():
	set_process(true)
	_chBtnArr.connect('button_selected', self, '_on_choice_btnSelected')

func _process(delta):
	if((_viewDB.size() >= 1) && _canProgress):
		_contentType = _viewDB[_viewDB.size()-1]["type"]
		_viewShield.set_hidden(false)
		_canProgress = false
		if(_contentType == "dialogue"):
			_dialogueLogic()
		elif(_contentType == "choice"):
			_choiceLogic()
		elif(_contentType == "photo"):
			_photoLogic()


#---DISPLAY _viewDB contents (just display thier respective overlay)
func _dialogueLogic(): 
	_dlText.clear()
	_dlText.add_text(_viewDB[_viewDB.size()-1]["content"])
	_dlThumb.set_texture(charThumbDict[_viewDB[_viewDB.size()-1]["name"]])
	_dlText.set_hidden(false)
	_dlThumb.set_hidden(false)
	_viewDB.pop_back()

func _choiceLogic():
	_chBtnArr.clear()
	_chBtnArr.get_parent().set_hidden(false)
	for item in _viewDB[_viewDB.size()-1]["content"]:
		_chBtnArr.add_button(item)
	_viewDB.pop_back()

func _photoLogic():
	_phSprite.set_hidden(false)
	if(_viewDB[_viewDB.size()-1]["preloaded"]):
		_phSprite.set_texture(_viewDB[_viewDB.size()-1]["content"])
	else:
		_phSprite.set_texture(load(_viewDB[_viewDB.size()-1]["content"]))
	
	_viewDB.pop_back()