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


// Used by Command/MUD/Look
mob/proc/lookAt(atom/a)
	if(!client) return
	if(!a)
		if(istype(loc, /room))
			var/room/R = loc
			sendTxt(R.describeTo(src), src)
		else
			sendTxt("Unidentified location. Please report.", src, 0)
			return
	else
		if(istype(a, /atom))
			sendTxt(a.describeTo(src), src)

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
			sendTxt("Bye!", user, DT_MISC, 0)
			// TODO: Implement logging out

	Who
		format = "~'who'"
		Process(mob/user)
			..()
			var/list/players=connection_manager.getOnlinePlayers()
			sendTxt("The following players are online ([length(players)]):", user, DT_MISC, 0)
			for(var/mob/M in players)
				sendTxt(M.getName(), user, DT_MISC, 0)

	Look
		format = "~'look'|~'glance'; ?'at'; obj(contents, user)|obj(ground, user)|mob(ground, user)"
		Process(mob/user, obj/O)
			..()
			user.lookAt(O)

	Reboot
		format = "'reboot'"
		Process(mob/user)
			..()
			//world.Reboot()

	Commands
		format = "~'commands'"
		Process(mob/user)
			..()
			sendTxt("The following commands are available to you:", user, DT_MISC, 0)
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
				. += "\n\[0m[centerText("\[[a]\]", "-", 65)]\n"
				for(var/b in L)
					word_wrap -= length(b)
					if(word_wrap < 0)
						word_wrap = 50
						. += "\n"
					. += "[b] "
			sendTxt(., user, DT_MISC, 0)
			//sendTxt("Type help \<command name\> for more information on a command.", user, DT_MISC, 1)

