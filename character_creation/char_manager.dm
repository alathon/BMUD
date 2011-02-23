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
		__createLoginMenu()
		if(!character_manager) character_manager = src
		..()

	Unloaded()
		if(character_manager == src) character_manager = null
		..()


	proc
		__createLoginMenu()
			var/menuAction/root = new(new/menu)
			var/menuAction/create = new(characterForm())
			var/menuAction/quit = new(new/menu("quit",
						"(#bQ#n)uit the game"))
			create.setCallback(new/callObject(src,"parseCharacterForm"))
			quit.setCallback(new/callObject(src,"quitClient"))
			root.attach(create, quit)
			menuOps.addMenu(root, "login")

		newClientConnection(client/C)
			if(!C || !istype(C))
				Log("Attempt to call newClientConnection with bad argument",
						EVENT_CHARACTER)
				return
			// TODO: Check whether the player was linkdead last, or
			// we're recovering from a hotboot or similar condition.
			showCharacterMenu(C)

		showCharacterMenu(client/C)

			var/menu/M = menuOps.getMenu("login")
			M.ask(C)

		quitClient(client/C, menu/M)
			SendTxt("Goodbye!", C)
			del C
			return menuOps.MENU_EXIT

		__verify_name(client/C, n)
			set name = "__verify_name"
			if(length(n) < 3 || length(n) > 15)
				return new/inputError("Name must be between 3 - 15 characters")

		__verify_password(client/C, n)
			set name = "__verify_password"
			if(length(n) < 7)
				return new/inputError("Password must be at least 7 characters.")

		characterForm()
			var/form/menu/F = new("create", "(#zC#n)reate a character")
			var/Input/I

			I = new("\nWhat is your name? (Type #zexit#n to quit)",
					inputOps.ANSWER_TYPE_ANY)
			I.setCallback(src, "__verify_name")
			F.addQuestion("name", I)

			I = new("\nWhat gender would you like to be? \[#zmale#y female#n\] (Hit enter for male)", inputOps.ANSWER_TYPE_LIST)
			I.setAnswerlist(list("male","female"))
			I.setDefault("male") // TODO:
			F.addQuestion("gender", I)

			I = new("\nPlease enter a password:",
					inputOps.ANSWER_TYPE_ANY)
			I.setConfirm("Please type it again:")
			I.setCallback(src, "__verify_password")
			F.addQuestion("password", I)

			return F

		parseCharacterForm(client/C, form/F)
			if(F.isComplete() && C)
				var/char_name = F.getAnswer("name")
				var/char_pass = F.getAnswer("password")
				var/char_gender = F.getAnswer("gender")

				var/mob/M = new()
				var/mob/Old = C.mob
				M.key = C.key
				M.name = uppertext(copytext(char_name, 1, 2))+copytext(char_name, 2)
				M.gender = char_gender
				M.password = char_pass // Todo: Hash it
				if(Old) del Old
				M.keywords = list(lowertext(M.name),"mobile","player")
				M.Move(room_manager.GetRoom(1,1))
				return menuOps.MENU_EXIT
			else return menuOps.MENU_REPEAT
/*
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
				return character_manager.generateChar(C, "default")

	load_char
		Do(client/C)
			if(character_manager)
				return character_manager.loadChar(C, "default")

	about
		Do(client/C)
			.  = "BMUD is currently in beta!\n"
			. += "This means that there will be lots of bugs, missing features, et cetera.\n"
			. += "Please bear with me, during this time :) I'll think of a more creative about text later.\n"
			SendTxt(., C)
			. = MENU_REPEAT
*/
