/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\character_creation\char_template.dm

Character templates need to be revised - They're a bit iffy at the moment.
*/

char_template
	proc
		verify_name(client/C, n)
			if(length(n) < 3 || length(n) > 15)
				return new/inputError("Name must be between 3 - 15 characters")

		verify_password(client/C, n)
			if(length(n) < 7)
				return new/inputError("Password must be at least 7 characters.")

		genChar(client/C)
			var/form/F = new()
			var/Input/I

			I = new("\nWhat is your name? (Type #zexit#n to quit)",
					inputOps.ANSWER_TYPE_ANY)
			I.setCallback(src, "verify name")
			F.addQuestion("name", I)

			I = new("\nWhat gender would you like to be? \[#zmale#y female#n\] (Hit enter for male)", inputOps.ANSWER_TYPE_LIST)
			I.setAnswerlist(list("male","female"))
			I.setDefault("male") // TODO:
			F.addQuestion("gender", I)

			I = new("\nPlease enter a password:",
					inputOps.ANSWER_TYPE_ANY)
			I.setConfirm("Please type it again:")
			I.setCallback(src, "verify password")
			F.addQuestion("password", I)
			F.begin(C)
			if(F.isComplete() && C)
				var/char_name = F.getAnswer("name")
				var/char_pass = F.getAnswer("password")
				var/char_gender = F.getAnswer("gender")
				del F

				var/mob/M = new()
				var/mob/Old = C.mob
				M.key = C.key
				M.name = uppertext(copytext(char_name, 1, 2))+copytext(char_name, 2)
				M.gender = char_gender
				M.password = char_pass // Todo: Hash it
				if(Old) del Old
				M.keywords = list(lowertext(M.name),"mobile","player")
				M.Move(room_manager.GetRoom(1,1))
				return M
			else return C
