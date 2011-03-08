# Instructions

In order to compile and run this project, you must have BYOND installed.
BYOND is a programming language aimed at the creation of 2D games, that
also supports telnet connections. It runs a virtual machine, and handles
client/server communication amongst other things for you. The language is
quite nice to deal with in many ways.

* Download [BYOND](http://www.byond.com/download/) for Linux
* Follow the instructions in the README.
* Run 'make depend' in the bmud root dir. This will download dependencies.
* Run 'make'. This will compile the game, the compiled VM executable has the .dmb extension
* Edit run.sh if you want to change the port the game is hosted on. 5555 by default
* To run the game, use run.sh (or check out the command and call it manually). Note
that it doesn't screen or use & or anything by default.
* Connect to the game over telnet on the port specified.

# What is BYOND?

BYOND is a programming language aimed at the creation of 2D/Isometric online games,
which also happens to support telnet and as such is viable for the creation of MUDs.
BYOND runs in a virtual machine, and handles client/server networking for you. Its
single-threaded, and the language is quite nice to deal with. 

# So what do the different files do?

The code documentation is VERY minor at the moment. That should change when I have time,
but until then, here is a short rundown of some key stuff:

* src/booting.dm - Boots up the world. The boot process uses Alathon.bootprocess
* src/parser/parser.dm - Implements the parser. Uses AbyssDragon.Parser
* Alathon.telnet_input - Library responsible for gathering input from the user
* src/parser/chat.dm - Some example chat-related commands. Check out the other files here too
* src/item_stacking/ - An implementation of item stacking
* src/char_manager.dm - The service that handles character creation/saving/loading

# Where are those libraries?

BYOND will, at least with default settings, store libraries under ~/.byond/lib/, separated by
author of the library. So ~/.byond/lib/alathon/callwrapper/ is the Alathon.callwrapper library.

Check out the Makefile under depend: to see how DreamDownload works, a downloader for libraries.
