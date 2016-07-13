# Godot Adventure Framework

## Description
Adventure/Visual Novel framework for the Godot Engine.
Basically, using a simple API, you can setup 'clickables' that you can click/tap to:
* start dialogue/conversation with characters that have different 'thumbnails'
* show a choice & run a callback function with the result
* show an overlay ('photo') during a dialogue
You would use Godot's built in functionality to change scenes, add music, etc.

##Getting Started
1. Clone this repository or download it
2. In the Godot project manager, select 'import' to add this project
3. Get started by glancing at the template scene & reading the docs below

##Documentation

###Basic usage

1. Open up the template scene (only scene included), this will serve as a basic game scene
2. The whole framework is in GameManager.gd, it includes the functions you need
3. Insert 'clickables' (items in game the user can click) and .connect() them
4. Start using the API! Note that ClickManager.gd is there so you can test the framework

###The API

#### Reference GameManager.gd (anywhere in the template scene)
```gdscript
onready var g = get_tree().get_root().get_node('GameManager')
```
#### Add the Characters & thier thumbnails
```gdscript
g.charThumbDict['Harold Finch'] = preload('res://assets/sample/s_Finch.png')
g.charThumbDict['Clime'] = preload('res://assets/sample/s_Clime.png')
#...for each character...
```
#### Add a dialogue (conversations that can characters have)
```gdscript
g.dialogue('Clime', "Hi! I am Clime, and this is something I'm saying!", 0)
g.dialogue('Harold Finch', 'Hey Clime, nice to meet you!', 0)
g.dialogue('Clime', 'Do you prefer cats or dogs?', 0)
```
#### Add a choice (choice the player has to make that influence game flow)
```gdscript
g.choice(['I prefer cats!', 'I prefer dogs!'], '_ch_catsOrDogs', self, 0)

var lovesCatsOrDogs = '' #so we can use the selection later

func _ch_catsOrDogs(selection):
  if selection == 0:
    lovesCatsOrDogs = 'cats'
    g.dialogue('Clime', 'Oh, so you prefer cats I see...', 0)
  elif selection == 1:
    lovesCatsOrDogs = 'dogs'
    g.dialogue('Clime', 'Dogs it is!', 0)
  g.dialogue('Clime' 'Prefer any species?', 0)
  g.choice(['Not really...', 'O yes!'], '_ch_speciesPref', self, 0)

func _ch_speciesPref(selection):
  #...and so on...
```
_Note how whenever there's a choice, the game execution **has** to continue from the callback function_
#### Add a mid-conversation photo
```gdscript
g.photo('res://assets/sample/samplePhoto.png', false, 0)
#--OR--
var preloadedPhoto = preload('res://assets/sample/samplePhoto.png')
g.photo(preloadedPhoto, true, 0)
```
_Note you can't just hide/show a photo using normal Godot scripting due to the framework's internal implementation (see implementation note below)_

### Extra configuration
Optional configurations accepted. Set them in _ready() before using any of the framework's function to take effect.

Different clearing styles:
```gdscript
g.clearMode = 0 #dialogues/photos aren never displayed with choices, 
            = 1 #last dialogue/photo stays when there's a choice
```
_planned in the future:_
```gdscript
g.clearTimeout = 0 #default, show next dialogue/photo/choice on user click
               = n #show next dialogue/photo/choice after n milliseconds
```
```gdscript
g.keepThumb(charName) 
#keep the thumbnail of a character on screen even after finishing dialogue (VN-style)
g.removeThumb(charName) #remove kept thumbnail
```
### What are all these zeroes at the end?
They will be used in the future to implement a system where you could vary the position of the GUI elements.
This could be used to position the character thumbnails in different positions during a conversation, etc.

### Note about framework implementation

The framework works by adding all ```dialogue()```, ```choice()```, and ```photo()``` call parameters into a FIFO-style array at runtime.
This means that any logic you execute between two of these functions will happen _after both these functions' effect has executed_.

This is the reason you can't just do a sprite.set_hidden(false) in the middle of multiple dialogue functions.
It also means that whenever choice() is used, _all_ following game logic/other functions should be executed after the choice's callback function runs.

(if a better implementation is ever contributed, it will be accepted with open arms!)

