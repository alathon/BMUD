/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\help\help.dm

The help datum represents a single helpfile.

Helpfiles have related helpfiles, keywords, a text body and a name.

*/
help
	var
		name = ""
		list
			keywords
			see_also

	proc
		SetKeywords()
		SetSimilar()
		SetColors()
		SetText()
		SetName()
