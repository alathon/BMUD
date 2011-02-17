/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\core\parser\chat.dm

Defines a set of chat commands for use in the game
*/
Command/MUD/Chat
	category = "\[1;32mCommunication\[0m"
	Tell
		format = "~'tell'|~'whisper'; $~mob(online_players); anything"
		Process(mob/user, mob/target, T)
			..()
			T = html_encode(T)

			if(target == src)
				SendTxt("Getting lonely, are we?", user, DT_MISC, 0)
				return 1

			if(!T || T == " ")
				SendTxt("Tell [target.getName()] what?", user, DT_MISC, 0)
				return 1


			SendTxt("You tell [target.getName()], '[T]'", user, DT_PRIV)
			SendTxt("[user.getName()] tells you, '[T]'", target, DT_PRIV)
			Log("[user.getName()] tells [target.getName()], '[T]'", EVENT_CHAT)
			return 1

		Tell_error
			category = ""
			format = "~'tell'|~'whisper'; anything"
			Process(mob/user, T)
				SendTxt("Cannot find [copytext(T,1,findtext(T," "))]. See help tell for more information.\n", user, DT_MISC, 0)
				return 1

	Say
		format = "~'say'; anything"
		Process(mob/user, T)
			..()
			T = html_encode(T)
			if(!T || T == " ")
				SendTxt("Say what?", user, DT_MISC, 0)
				return 1

			if(user.loc)
				for(var/mob/M in user.loc.contents - user)
					SendTxt("[user.getName()] says, '[T]'#n", M, DT_MISC)
				SendTxt("You say, '[T]'#n", user, DT_MISC)
				Log("[user.getName()] says, '[T]'", EVENT_CHAT)
				return 1
