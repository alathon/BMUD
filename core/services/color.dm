/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Gr�nbaum, 2007

bmud2\core\services\color.dm

Implements a color system, where # can be followed by a sequence character to
be changed into the appropriate colorization method (HTML or ANSI Escape sequences)
depending on client type.

Use color_manager.Colorize(text, client_type) to recieve a returned, colorized string.
*/
#define COLORCHAR "#"

// HTML-specific constants
#define EXPECT_CHAR 0
#define EXPECT_CCODE 1
#define TELNET_COLOR CLIENT_TELNET
#define HTML_COLOR CLIENT_DS



var/_service/color_manager/color_manager
_service/color_manager
	name = "ColorManager"

	var
		list
			html_sequences = list()
			telnet_sequences = list()

	proc
		FindHTMLSequence()
		FindTelnetSequence()
		Colorize()
		ParseHTML()
		ParseTelnet()
		TelnetColor()
		HTMLColor()

	Loaded()
		if(!color_manager) color_manager = src
		for(var/A in typesof(/sequence/html/) - /sequence/html)
			html_sequences += new A()
		for(var/A in typesof(/sequence/telnet/) - /sequence/telnet)
			var/sequence/S = new A()
			telnet_sequences += S.character
			telnet_sequences[S.character] = S

	Unloaded()
		if(color_manager == src) color_manager = null
		for(var/sequence/S in html_sequences)
			del S
		for(var/sequence/S in telnet_sequences)
			del S
		html_sequences = null
		telnet_sequences = null

	Colorize(text, color_mode = TELNET_COLOR)
		switch(color_mode)
			if(TELNET_COLOR)
				return TelnetColor(text)
			if(HTML_COLOR)
				return HTMLColor(text)
			else
				Log("Invalid arguments to colorize: colorize([text], [color_mode])", EVENT_PROCFAIL)

	FindHTMLSequence(i)
		var/tmp
			setBold = 0
			color   = ""
		for(var/sequence/S in html_sequences)
			if(cmptextEx(i,S.character))
				color = S.function()
				if(cmptext(copytext(color,length(color) - 2),"<b>"))
					setBold = 1
				color = S.function()
				break
		return list(color,setBold)

	FindTelnetSequence(i)
		if(i in telnet_sequences)
			var/sequence/S = telnet_sequences[i]
			return S.function()
		return null


	TelnetColor(t)
		var/tmp
			tlen = length(t)
			color_val = ""
			seq = ""
			start = 1
			next  = findtext(t, "#")

		if(!next) return t

		while(next)
			if(!(start == next)) // # at start is baad
				. += copytext(t, start, next) // Copy up until color character.

			if(next == tlen)
				break // End of string

			color_val = copytext(t, next+1, next+2)
			seq = FindTelnetSequence(color_val)
			if(!seq)
				. += "[color_val]"
			else
				. += seq
			start = next + 2
			next = findtext(t, "#", start)

		if(next != tlen)
			. += copytext(t, start, 0)

	HTMLColor(t)
		var/tmp
			tlen = length(t)
			i = 1
			mode = 0
			newmsg = ""
			char = ""
			code = ""
			bold_count = 0
			bold = 0
			colorcodes = 0
			list
				sequence_info = list()

		for(i=1, i <= tlen, i++)
			char = copytext(t,i,i+1)
			if(cmptext(char,COLORCHAR))
				mode = !mode
				if(mode == EXPECT_CHAR)
					newmsg += "[COLORCHAR]"
				continue

			else
				if(mode == EXPECT_CHAR)
					newmsg += char
					continue

				else if(mode == EXPECT_CCODE)
					sequence_info = FindHTMLSequence(char)
					code = sequence_info[1]
					bold = sequence_info[2]
					if(!code)
						newmsg += "[COLORCHAR][char]"
						mode = !mode
						continue

					else
						if(!colorcodes)
							newmsg += "[code]"
							colorcodes = 1
						else
							if(bold_count)
								newmsg += "</b>"
								bold_count--
							newmsg += "</font>"
							newmsg += "[code]"
						if(bold)
							bold_count++
						mode = !mode

						code = ""
						continue
		sequence_info = null
		return newmsg

sequence
	New() // Dont care about sequences keys/creation. So dont log or give keys


	var/tmp
		name = ""
		character = ""

	proc
		function()

	html
		Black
			name = "black"
			character = "d"
			function() return "<font color=[rgb(0,0,0)]>"
		Dark_Gray
			name = "dark gray"
			character = "z"
			function() return "<font color=[rgb(120,120,120)]>"
		Gray
			name = "gray"
			character = "Z"
			function() return "<font color=[rgb(180,180,180)]>"
		White
			name = "white"
			character = "w"
			function() return "<font color=[rgb(255,255,255)]>"
		Cyan
			name = "cyan"
			character = "c"
			function() return "<font color=[rgb(0,207,207)]>"
		Bright_Cyan
			name = "bright cyan"
			character = "C"
			function() return "<font color=[rgb(0,255,255)]>"
		Magenta
			name = "magenta"
			character = "m"
			function() return "<font color=[rgb(207,0,207)]>"
		Bright_Magenta
			name = "bright magenta"
			character = "M"
			function() return "<font color=[rgb(255,0,255)]>"
		Yellow
			name = "yellow"
			character = "y"
			function() return "<font color=[rgb(207,207,0)]>"
		Bright_Yellow
			name = "bright yellow"
			character = "Y"
			function() return "<font color=[rgb(255,255,0)]>"
		Red
			name = "red"
			character = "r"
			function() return "<font color=[rgb(207,0,0)]>"
		Bright_Red
			name = "bright red"
			character = "R"
			function() return "<font color=[rgb(255,0,0)]>"
		Blue
			name = "blue"
			character = "b"
			function() return "<font color=[rgb(0,0,207)]>"
		Bright_Blue
			name = "bright blue"
			character = "B"
			function() return "<font color=[rgb(0,0,255)]>"
		Green
			name = "green"
			character = "g"
			function() return "<font color=[rgb(0,207,0)]>"
		Bright_Green
			name = "bright green"
			character = "G"
			function() return "<font color=[rgb(0,255,0)]>"
		Reset
			name = "reset"
			character = "n"
			function() return "</font>"
	telnet
		Black
			name = "black"
			character = "d"
			function() return "\[0;30m"
		Dark_Gray
			name = "dark gray"
			character = "z"
			function() return "\[1;30m"
		Gray
			name = "gray"
			character = "Z"
			function() return "\[0;37m"
		White
			name = "white"
			character = "w"
			function() return "\[1;37m"
		Cyan
			name = "cyan"
			character = "c"
			function() return "\[0;36m"
		Bright_Cyan
			name = "bright cyan"
			character = "C"
			function() return "\[1;36m"
		Magenta
			name = "magenta"
			character = "m"
			function() return "\[0;35m"
		Bright_Magenta
			name = "bright magenta"
			character = "M"
			function() return "\[1;35m"
		Red
			name = "red"
			character = "r"
			function() return "\[0;31m"
		Bright_Red
			name = "bright red"
			character = "R"
			function() return "\[1;31m"
		Blue
			name = "blue"
			character = "b"
			function() return "\[0;34m"
		Bright_Blue
			name = "bright blue"
			character = "B"
			function() return "\[1;34m"
		Green
			name = "green"
			character = "g"
			function() return "\[0;32m"
		Bright_Green
			name = "bright green"
			character = "G"
			function() return "\[1;32m"

		Yellow
			name = "yellow"
			character = "y"
			function() return "\[0;33m"
		Bright_Yellow
			name = "bright yellow"
			character = "Y"
			function() return "\[1;33m"
		Reset
			name = "reset"
			character = "n"
			function() return "\[0m"
		Clear
			// This one only works in telnet clients, and a few
			// mud clients.
			name = "clear"
			character = "clear"
			function() return "\[2J"
