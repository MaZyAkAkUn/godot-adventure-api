
extends Node2D
#---PUBLIC CONFIG VARIABLES
var char_thumbs = {} #{"name": "thumb_preloaded"} #character thumbnail database
var char_voice = {} #{"name": [voices for the character]
var async_dialogues = true #if false, the dialogue becoems same as chocies/media

#---PRIVATE VARIABLES
var _viewDB = [] #LIFO structure that holds dialogues, choices, & medias
var _content_type = '' #determine type in _viewDB switch @ _process
var _can_progress = true #used to manage progression with _view_shield

var _current_cb = ''
var _current_caller = ''
var togg
onready var _dialogue_text = get_node('DialogueSys/DialogueText')
onready var _dialogue_thumb = get_node('DialogueSys/DialogueThumb')
onready var _choice_button_arr = get_node('ChoiceSys/ScrollContainer/VButtonArray')
onready var _media_sprite = get_node('MediaSys/Sprite')
onready var _media_audio = get_node('MediaSys/Audio')
onready var _view_shield = get_node('ViewShield')

#---PUBLIC API
func dialogue(char_name_str, text_str, pos_enum):
	_viewDB.push_front({"type": "dialogue", "content": text_str, "pos": pos_enum, "name": char_name_str})

func choice(choice_text_arr, callback_fn, caller_obj, pos_enum): 
	_viewDB.push_front({"type": "choice", "content": choice_text_arr, "pos": pos_enum}) 
	_current_cb = callback_fn
	_current_caller = caller_obj

func media(type_str, path_str, pos_enum):
	if (type_str == 'sprite'):
		_viewDB.push_front({"type": "media_sprite", "content": path_str, "pos": pos_enum})
	elif (type_str == 'audio'):
		_viewDB.push_front({"type": "media_audio", "content": path_str, "pos": pos_enum})

#---VIEW SHIELD IMPLEMENTATION (Should be on whenever there's dialogue/choice/media)
func _on_ViewShield_pressed():
	if(_choice_button_arr.get_parent().is_hidden()): #not in choice mode, can _progress
		_progress()

func _on_choice_btnSelected(btnId):
	_current_caller.call(_current_cb, btnId)
	_progress()

func _progress(): #(Let dialogue _progress, media disappear, or choice=-1)
	if(!async_dialogues && _viewDB.size() > 0):
		_clear()
	if(_viewDB.size() == 0): #if no more to _progress through, hide shield
		_view_shield.set_hidden(true)
	if(!_choice_button_arr.get_parent().is_hidden()): #hide any choices (if any)
		_choice_button_arr.get_parent().set_hidden(true)
	_media_sprite.set_hidden(true)
	_media_audio.stop_all()
	_can_progress = true

func _clear():
	_dialogue_text.clear()
	_dialogue_thumb.set_texture(null)
	_dialogue_text.set_hidden(true)
	_dialogue_thumb.set_hidden(true)
	_choice_button_arr.clear()
	_media_sprite.set_hidden(true)
	_media_audio.stop_all()


#---SWITCH TO DISPLAY _viewDB CONTENTS
func _ready():
	set_process(true)
	_choice_button_arr.connect('button_selected', self, '_on_choice_btnSelected')

func _process(delta):
	if((_viewDB.size() >= 1) && _can_progress):
		_content_type = _viewDB[_viewDB.size()-1]["type"]
		_view_shield.set_hidden(false)
		_can_progress = false
		if(_content_type == "dialogue"):
			_dialogueLogic()
		elif(_content_type == "choice"):
			_choiceLogic()
		elif(_content_type == "media_sprite" or _content_type == "media_audio"):
			_mediaLogic()


#---DISPLAY _viewDB contents (just display thier respective overlay)
func _dialogueLogic(): 
	_dialogue_text.clear()
	_dialogue_text.add_text(_viewDB[_viewDB.size()-1]["content"])
	_dialogue_thumb.set_texture(char_thumbs[_viewDB[_viewDB.size()-1]["name"]])
	_dialogue_text.set_hidden(false)
	_dialogue_thumb.set_hidden(false)
	_viewDB.pop_back()

func _choiceLogic():
	_choice_button_arr.clear()
	_choice_button_arr.get_parent().set_hidden(false)
	for item in _viewDB[_viewDB.size()-1]["content"]:
		_choice_button_arr.add_button(item)
	_viewDB.pop_back()

func _mediaLogic():
	if(_viewDB[_viewDB.size()-1]["type"] == "media_sprite"):
		_media_sprite.set_hidden(false)
		_media_sprite.set_texture(_viewDB[_viewDB.size()-1]["content"])
	elif(_viewDB[_viewDB.size()-1]["type"] == "media_audio"):
		_media_audio.play(_viewDB[_viewDB.size()-1]["content"])
	_viewDB.pop_back()