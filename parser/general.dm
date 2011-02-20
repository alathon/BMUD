/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\core\parser\general.dm

General, all purpose commands.
*/

Command
	New() //Set true_name, the first keyword encased in 's in the format string.
		  // Used by the commands command.
		..()
		var/first = findtext(format, "'")
		if(!first) return 1
		var/second = findtext(format, "'", first+1)
		if(!second) return 1
		true_name = copytext(format, first+1, second)
		return 1

Command/MUD
	category = "\[0;32mGeneral\[0m"
	Quit
		format = "'quit'|'exit'"
		Process(mob/user)
			..()
			SendTxt("Bye!", user, DT_MISC, 0)
			SendTxt("TODO: Implement logging out")
			//if(user.client)
			//	user.client.Logout()

	Who
		format = "~'who'"
		Process(mob/user)
			..()
			var/list/players=connection_manager.getOnlinePlayers()
			SendTxt("The following players are online ([length(players)]):", user, DT_MISC, 0)
			for(var/mob/M in players)
				SendTxt(M.getName(), user, DT_MISC, 0)

	Look
		format = "~'look'; ?'at'; obj(contents, user)|obj(ground, user)|mob(ground, user)"
		Process(mob/user, obj/O)
			..()
			user.Look(O)

	Reboot
		format = "'reboot'"
		Process(mob/user)
			..()
			//world.Reboot()

	Commands
		format = "~'commands'"
		Process(mob/user)
			..()
			SendTxt("The following commands are available to you:", user, DT_MISC, 0)
			var/list/categories = list()
			for(var/Command/C in parser.Commands)
				if(C.Allow(user) && C.category && C.true_name)
					if(!(C.category in categories))
						categories += C.category
						categories[C.category] = list()
					var/list/L = categories[C.category]
					L += C.true_name
			for(var/a in categories)
				var/list/L = categories[a]
				var/word_wrap = 50
				. += "\n\[0m[Center("\[[a]\]", "-", 65)]\n"
				for(var/b in L)
					word_wrap -= length(b)
					if(word_wrap < 0)
						word_wrap = 50
						. += "\n"
					. += "[b] "
			SendTxt(., user, DT_MISC, 0)
			//SendTxt("Type help \<command name\> for more information on a command.", user, DT_MISC, 1)

