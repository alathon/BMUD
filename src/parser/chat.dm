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

Command/MUD/Chat
	category = "\[1;32mCommunication\[0m"
	Tell
		format = "~'tell'|~'whisper'; $~mob(online_players); anything"
		Process(mob/user, mob/target, T)
			..()

			if(target == src)
				sendTxt("Getting lonely, are we?", user, DT_MISC, 0)
				return 1

			if(inputOps.isEmpty(T))
				sendTxt("Tell [target.getName()] what?", user, DT_MISC, 0)
				return 1


			sendTxt("You tell [target.getName()], '[T]'", user, DT_PRIV)
			sendTxt("[user.getName()] tells you, '[T]'", target, DT_PRIV)
			Log("[user.getName()] tells [target.getName()], '[T]'", EVENT_CHAT)
			return 1

		Tell_error
			category = ""
			format = "~'tell'|~'whisper'; anything"
			Process(mob/user, T)
				sendTxt("Cannot find [copytext(T,1,findtext(T," "))]. See help tell for more information.\n", user, DT_MISC, 0)
				return 1

	Say
		format = "~'say'; anything"
		Process(mob/user, T)
			..()
			if(inputOps.isEmpty(T))
				sendTxt("Say what?", user, DT_MISC, 0)
				return 1

			if(user.loc)
				for(var/mob/M in user.loc.contents - user)
					sendTxt("[user.getName()] says, '[T]'#n", M, DT_MISC)
				sendTxt("You say, '[T]'#n", user, DT_MISC)
				Log("[user.getName()] says, '[T]'", EVENT_CHAT)
				return 1
