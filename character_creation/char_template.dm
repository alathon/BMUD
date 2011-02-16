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

		GenChar(client/C)
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

/*
character_template
	var/list/fields

	proc
		GenChar()
		AddField()
		RemField()
		GetField(n)

	GenChar(client/C)
		var/mob/M = new()
		M.loc = null
		for(var/a = 1, a <= length(fields), a++)
			var/f = fields[a]
			var/v = fields[f]
			if(call(src,v)(C, M) == -1) // Back to main menu
				del M
				return MENU_REPEAT

		if(C && M && M.name && M.gender && M.password)
			var/mob/Old = C.mob
			M.key = C.key
			//M._text = "1;37m@" // Phased out: Support for map
			M.text  = "<font color=#00ff00>@</font>"
			if(Old) del Old
			M.keywords = list(lowertext(M.name), "mobile", "player")
			M.Move(room_manager.GetRoom(1,1))
			return M
		else
			del M
			return MENU_REPEAT

	AddField(name, value)
		if(fields && (name in fields)) return 0
		if(!fields) fields = new()
		fields += name
		fields[name] = value

	RemField(name)
		if(!fields || !(name in fields)) return 0

		fields -= name
		if(!length(fields)) fields = null





// Default character template
character_template/default
	New()
		..()
		AddField("name", "charname")
		AddField("gender", "chargender")
		AddField("passwd", "charpasswd")

	proc

		charname(client/C, mob/M)
			spawn() while(1)
				var/answer = ERROR_INPUT
				while(answer == ERROR_INPUT)
					var/Input/I = new(C, "\nWhat is your name? (Type #rexit#n to quit)")
					answer = I.getInput()

				if(answer == "exit") return -1

				if(length(answer) < 3 || length(answer) > 15)
					SendTxt("Your name must be between #z3#n and #z15#n characters long.", C, DT_MISC)
					continue

				var/try_again = FALSE
				for(var/i = 1, i <= length(answer), i++)
					var/ascii_char = text2ascii(answer, i)
					if(ascii_char < 97 || ascii_char > 122)
						SendTxt("Your name may only contain alphabetical characters, #za#n to #zz#n.", C, DT_MISC)
						try_again = TRUE
						break
				if(try_again) continue
				. = answer
				break

			M.name = uppertext(copytext(., 1, 2)) + copytext(., 2)

		chargender(client/C, mob/M)
			. = 0
			while(!.)
				if(!C) return 0

				SendTxt("\nYou can be either #Rmale#n or #Yfemale#n.", C, DT_MISC)

				. = lowertext(IO.Input("\nTake your pick! (Type #rexit#n to quit)", C, list("male","female","exit"), 1, 0, "male"))

				if(. == "exit")
					return -1

			M.gender = .
			SendTxt("You have chosen #z[.]#n!", C, DT_MISC)

		charpasswd(client/C, mob/M)
			. = 0
			while(!.)
				if(!C) return 0
				. = IO.Input("\nWhat do you want your password to be? (Type #rexit#n to quit)", C, ANSWER_TEXT)

				if(. == "exit")
					return -1

				var/clen = length(.)

				if(clen < 5)
					SendTxt("You must have at least #z5#n characters in your password.", C, DT_MISC)
					. = 0
					continue

				for(var/i = 1, i <= clen, i++)
					var/ascii_char = text2ascii(., i)
					if(!(ascii_char > 47 && ascii_char < 58) && !(ascii_char > 96 && ascii_char < 123))
						SendTxt("Your password may only contain #zletters#n and #znumbers#n.", C, DT_MISC)
						. = 0
						break

				var/confirm = IO.Input("\nPlease confirm by typing the same password again.", C, ANSWER_TEXT)
				if(confirm != .)
					. = 0
					SendTxt("Passwords don't match. Try again.", C, DT_MISC, 0)

			M.password = .
*/
