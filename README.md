# playdate_album

A little project to allow publishing music on Panic's Playdate console (https://play.date/)

You can drop audio files, lyric text files, album art and about/help text into this project, 
compile it all with the playdate compiler (pdc, find it at https://play.date/dev/), download 
to your Playdate, and enjoy. Follow the templates for album_data.lua and lyric, help and about 
files.

Provides some basic controls for view lyrics, setting volume, track select, and scrubbing 
through the audio using the crank. Use 'B' button to select mode - single click for lyrics,
double click to volume, triple click for track select / scrubbing. Help and about texts are
accessed through the Playdate system menu.

You can include as much art as you like, changing between images with the 'A' button.
The D-pad will move the image if it is bigger than the Playdate's display. I recommend
you leave the album art as big as possible, it is fun to hunt through the detail of a big 
image while listening to your music!

Licence and attribution for the font is in main.lua.

Thanks for looking.
