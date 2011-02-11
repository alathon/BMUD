/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Gr�nbaum, 2007

bmud2\objects\menu.dm

A menu is a collection of items, which each have their own run procedure. Items can hotlink
to other menues, creating the effect of submenues.
*/

menu
	var
		header = ""
		list
			choices
		menu/father = null
		numbered = 1
		no_exit = 0
		lowertext = 0
		init = 0

	proc
		Display()
		Create()
		GetInput()
		Cleanup()

	Cleanup(children = 1, kill_father = 0)
		if(children) for(var/a in choices)
			var/item/I = choices[a]
			if(!istype(I, /item)) break // Already done once? Not created, at least.
			if(I.dest)
				I.dest.Cleanup(1, 0)
			del I

		if(kill_father && father)
			father.Cleanup(0, 1) // Move up the tree as well.
		del src

	Create() // Generate sub-menues and items based on choices list.
		if(!choices || !length(choices)) del src
		var/list/L = new()
		for(var/a = 1, a <= length(choices), a++)
			var/ref = choices[a]
			var/list/choice = choices[ref]
			var/path = choice[1]
			var/item/I = new path()
			I.father = src
			I.header = choice[2]
			L += ref
			L[ref] = I

		choices = L
		init = 1

	GetInput(client/C)
		var/answer == inputOps.ERROR_INPUT
		while(answer == inputOps.ERROR_INPUT)
			SendTxt(Display(C), C, DT_MENU)
			var/Input/I = new(C, header)
			answer = I.getInput()

		if(!get)
			return GetInput(C)

		if(lowertext) get = lowertext(get)
		for(var/a in choices)
			if(!C)
				Cleanup()
			if(Short2Full(get, a, 1)) // Match
				var/item/I = choices[a]
				var/item_return = I.Do(C)
				if(item_return == MENU_BACK)
					if(father)
						C.SetMenu(father)
					else
						C.SetMenu(null)
					Cleanup()
				else if(item_return == MENU_REPEAT)
					break
				else
					return item_return

		. = GetInput(C)

	Display()
		for(var/a in choices)
			var/item/I = choices[a]
			. += "[I.header]"


item
	var
		header = ""
		menu/father = null
		menu/dest   = null

	proc
		Do(client/C)
			. = ..()
			if(dest)
				if(!dest.init) dest.Create()
				C.SetMenu(dest)

// Generic exit item. Quits the client, and cleans up the menu.
item/exit
	Do(client/C)
		if(!C || !istype(C, /client)) return 0
		var/menu/M = C.current_menu
		if(M)
			M.Cleanup(1,1)
		C.ExitGame()

// Generic back item. Either moves up one menu, or cleans up the menu if its a total exit from it.
item/back
	Do(client/C)
		if(!C || !istype(C, /client)) return 0
		var/menu/M = C.current_menu
		if(M)
			if(M.father)
				C.SetMenu(M.father)
			else
				C.SetMenu(null)
				M.Cleanup(1,1) // Destroy both ways throughout the tree.


