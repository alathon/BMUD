/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\character_creation\char_manager.dm

The character manager handles players sent to it by the connection handler. It
generates a login menu for each player its sent in CharacterMenu(C), and the login
menu will in turn call GenerateChar().

Loading and saving characters isn't implemented yet.
*/

var/_service/character_manager/character_manager
_service/character_manager
	name = "CharacterManager"
	dependencies = list("ConnectionManager", "IO")

	Loaded()
		if(!character_manager) character_manager = src
		..()

	Unloaded()
		if(character_manager == src) character_manager = null
		..()


	proc
		CharacterMenu()
		LoadChar()
		GenerateChar()


	CharacterMenu(client/C)
		if(!C || !istype(C, /client)) return 0
		var/menu/login_menu/index/I = new()
		I.Create()
		var/menu_input = I.GetInput(C)
		// Clean up the menu
		I.Cleanup(1,1)
		return menu_input

	LoadChar(client/C)
		if(!C || !istype(C, /client)) return 0
		SendTxt("\nThis feature is not yet available. Sorry!\n", C, DT_MISC, 0)
		return MENU_REPEAT

	GenerateChar(client/C, temp_name)
		if(!C || !istype(C, /client)) return 0

		var/char_template/T = new()
		return T.GenChar(C)

// Login menu and character creation/loading
menu/login_menu/index
	header = "What do you wish to do?"
	choices = list("create" = list(/item/login_menu/create_char, "#z(#gC#z)#nreate a new character\n"),
					"load" = list(/item/login_menu/load_char, "#z(#mL#z)#noad an existing character\n"),
					"about" = list(/item/login_menu/about, "Read #z(#bA#z)#nbout the MUD\n"),
					"exit" = list(/item/exit, "#z(#rE#z)#nxit the MUD\n"))

item/login_menu
	create_char
		Do(client/C)
			if(character_manager)
				return character_manager.GenerateChar(C, "default")

	load_char
		Do(client/C)
			if(character_manager)
				return character_manager.LoadChar(C, "default")

	about
		Do(client/C)
			.  = "BMUD is currently in beta!\n"
			. += "This means that there will be lots of bugs, missing features, et cetera.\n"
			. += "Please bear with me, during this time :) I'll think of a more creative about text later.\n"
			SendTxt(., C)
			. = MENU_REPEAT












