
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



		characterForm()
			var/form/menu/F = new("create", "(#zC#n)reate a character")
			var/Input/I

			I = new("\nWhat is your name? (Type #zexit#n to quit)",
					inputOps.ANSWER_TYPE_ANY)
			I.setCallback(src, "  verify name") // Use underscores when hascall() is fixed
			F.addQuestion("name", I)

			I = new("\nWhat gender would you like to be? \[#zmale#y female#n\] (Hit enter for male)", inputOps.ANSWER_TYPE_LIST)
			I.setAnswerlist(list("male","female"))
			I.setDefault("male")
			F.addQuestion("gender", I)

			I = new("\nPlease enter a password:",
					inputOps.ANSWER_TYPE_ANY)
			I.setConfirm("Please type it again:")
			I.setCallback(src, "  verify password") // Use underscores when hascall() is fixed
			F.addQuestion("password", I)

			return F

		__quitClient(client/C, menu/M)
			sendTxt("Goodbye!", C)
			del C
			return menuOps.MENU_EXIT

		__createLoginMenu()
			var/menuAction/root = new(new/menu)
			var/menuAction/create = new(characterForm())
			var/menuAction/quit = new(new/menu("quit",
						"(#bQ#n)uit the game"))
			create.setCallback(new/callObject(src,"  parseCharacterForm")) 
				// TODO: Change when hascall() is fixed
			quit.setCallback(new/callObject(src,"  quitClient"))
				// TODO: Change when hascall() is fixed
			root.attach(create, quit)
			menuOps.addMenu(root, "login")

		__verify_name(client/C, n)
			set name = "__verify_name"
				// TODO: Remove when hascall() is fixed
			if(length(n) < 3 || length(n) > 15)
				return new/inputError("Name must be between 3 - 15 characters")

		__verify_password(client/C, n)
			set name = "__verify_password"
				// TODO: Remove when hascall() is fixed
			if(length(n) < 7)
				return new/inputError("Password must be at least 7 characters.")

		__getMOTD()
			return "<Insert pretty Message of the Day here!>\nHit enter to continue"

		__showMOTD(client/C)
			if(!C) return

			var/Input/I = new(__getMOTD())
			I.setAllowempty(TRUE)
			I.getInput(C)

		__parseCharacterForm(client/C, form/F)
			if(F.isComplete() && C)
				var/char_name = F.getAnswer("name")
				var/char_pass = F.getAnswer("password")
				var/char_gender = F.getAnswer("gender")

				__showMOTD(C)

				var/mob/M = new()
				var/mob/Old = C.mob
				M.key = C.key
				M.setName(char_name)
				M.setGender(char_gender)
				C.setPassword(char_pass)
				if(Old) del Old
				M.Move(room_manager.GetRoom(1,1))
				return menuOps.MENU_EXIT
			else return menuOps.MENU_REPEAT

