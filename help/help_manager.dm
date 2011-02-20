/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\help\help_manager.dm

The help manager manages helpfiles, and searches through them to find appropriate matches for queries.

*/

/*
Helpfile Index syntax:

Helpfile1 Path
Helpfile2 Path
Helpfile3 Path

Helpfile syntax:

helpfile_name
helpfile_keywords seperated by ;
helpfile_similar seperated by ;
helpfile_colors seperated by ; (name color, body color, similar color)

[Helpfile Name]\n
keywords = {keyword1;keyword2;keyword3}\n
*similar  = {helpfile name; helpfile name; helpfile name;}\n
*colors   = {name_color; body_color}\n
text here with spaces n stuff
[Helpfile Name]\n
...etc

* = Optional
*/

var/_service/help_manager/help_manager
_service/help_manager
	name = "HelpManager"
	dependencies = list("IO", "Parser")

	Loaded()
		if(!help_manager) help_manager = src

	Unloaded()
		if(help_manager == src) help_manager = null

	var
		list
			helpfiles[0]

	proc
		AddHelp()
		RemHelp()
		GenerateHelpfiles()
		FindHelp()
		FindHelpfile()
		InterpretFile()

	AddHelp(_n, _k, _s, _c, _b)
		if(FindHelpfile(_k)) return 0

		var/help/H = new()
		H.SetName(_n)
		H.SetKeywords(_k)
		H.SetSimilar(_s)
		H.SetColors(_c)
		H.SetText(_b)
		if(!helpfiles) helpfiles = new()
		return H

	InterpretFile(f)
		if(!fexists(f)) return 0

		var
			list/txt = Text2List(file2text(f), "\n")
			_name = ""
			list/_keywords
			list/_similar
			list/_colors
			_body = ""

		for(var/l = 1, l <= length(txt), l++)
			switch(l)
				if(1) // name
					_name = txt[l]
				if(2)
					_keywords = Text2List(txt[l], " ")
				if(3)
					_similar = Text2List(txt[l], " ")
				if(4)
					_colors = Text2List(txt[l], " ")
				else
					_body += "[txt[l]]\n"

		AddHelp(_name, _keywords, _similar, _colors, _body)

