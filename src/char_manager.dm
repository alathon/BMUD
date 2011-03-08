/*******************************************************************************
 * BMUD ("this program") is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 ******************************************************************************/

/*


*/
// Prevent the creation of a default mob for a client.
// Clients just logging in have no mob, then. This
// makes it easier to deal with.
world/mob = 0

var/service/charMan/character_manager
service/charMan
	name = "CharacterManager"

	bootHook()
		__createLoginMenu()
		if(!character_manager) character_manager = src
		return 1

	haltHook()
		if(character_manager == src) character_manager = null
		return 1


	proc
		newClientConnection(client/C)
			if(!C || !istype(C))
				Log("ERROR Attempt to call newClientConnection with bad argument",
						EVENT_GENERAL)
				return
			// TODO: Check whether the player was linkdead last, or
			// we're recovering from a hotboot or similar condition.
			showCharacterMenu(C)

		showCharacterMenu(client/C)
			var/menu/M = menuOps.getMenu("login")
			M.ask(C)



		characterForm()
			var/form/F = new("create", "(#zC#n)reate a character")
			var/Input/I

			I = new("\nWhat is your name? (Type #zexit#n to quit)",
					inputOps.ANSWER_TYPE_ANY)
			I.setCallback(src, "__verify_name")
			F.addQuestion("name", I)

			I = new("\nWhat gender would you like to be? \[#zmale#y female#n\] (Hit enter for male)", inputOps.ANSWER_TYPE_LIST)
			I.setAnswerlist(list("male","female"))
			I.setDefault("male")
			F.addQuestion("gender", I)

			I = new("\nPlease enter a password:",
					inputOps.ANSWER_TYPE_ANY)
			I.setConfirm("Please type it again:")
			I.setCallback(src, "__verify_password")
			F.addQuestion("password", I)

			return F

		__quitClient(client/C, menu/M)
			sendTxt("Goodbye!", C)
			del C
			return menuOps.MENU_EXIT

		__runCharacterForm(client/C, menu/M)
			var/form/F = characterForm()
			var/exit = F.begin(C)

			if(exit == formOps.EXIT_DISCONNECT)
				return menuOps.MENU_EXIT
			else if(exit == formOps.EXIT_EXIT)
				return menuOps.MENU_BACK
			else if(exit == formOps.EXIT_COMPLETE)
				return __parseCharacterForm(C,F)

		__createLoginMenu()
			var/menu/root = new()
			var/menu/create = new("create", "(#gC#n)reate a character")
			var/menu/quit = new("quit", "(#bQ#n)uit the game")
			create.setCallback(new/callObject(src,"__runCharacterForm"))
			quit.setCallback(new/callObject(src,"__quitClient"))
			root.attach(list(create, quit))
			menuOps.addMenu(root, "login")

		__verify_name(client/C, n)
			if(length(n) < 3 || length(n) > 15)
				return new/inputError("Name must be between 3 - 15 characters")

		__verify_password(client/C, n)
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
			if(istype(C) && istype(F))
				var/char_name = F.getAnswer("name")
				var/char_pass = F.getAnswer("password")
				var/char_gender = F.getAnswer("gender")

				__showMOTD(C)

				var/mob/M = new()
				var/mob/Old = C.mob
				M.key = C.key
				M.setName(capitalize(char_name))
				M.setGender(char_gender)
				C.setPassword(char_pass)
				if(Old) del Old
				M.Move(room_manager.GetRoom(1,1))
			return menuOps.MENU_EXIT
