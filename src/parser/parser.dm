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


client/Command(T)
	if(__target)
		__target.receiveInput(T)
		return

	else if(!T || copytext(T, 1, 2) == " ")
		src << "> \..."
		return

	else if(parser && mob)
		if(parser.Parse(T, src.mob))
			Log("[(src.mob ? src.mob.name : src.ckey)]: [T]", EVENT_COMMAND)
		else
			Log("[(src.mob ? src.mob.name : src.ckey)]: [T]", EVENT_COMMAND)

	src << "> \..."

Command
	format = "" // Set default format to "", as opposed to the regular "&"

	priority = 1

	Set_List(List, Range, atom/temp_center)
		switch(List)
			if("loc")
				return temp_center.loc
			if("online_players")
				if(connection_manager) return connection_manager.getOnlinePlayers()
			if("online_clients")
				if(connection_manager) return connection_manager.getOnlineClients()
			if("linkdead_players")
				if(connection_manager) return connection_manager.getLinkdeadPlayers()
			if("ground")
				return temp_center.loc.contents
			if("groundmob")
				if(temp_center.loc)
					return temp_center.loc.contents + temp_center.contents
				return temp_center.contents
			else
				return ..(List, Range, temp_center)

	var
		true_name = ""
		category  = ""

	proc
		Allow(mob/user)
			return 1
		Allowed(mob/user)
			return 1
		Postprocess(mob/user)
			return 1

Parser/MUD
	Allowed = /Command/MUD/

	proc/checkMoveCommand(T, mob/M)
		if(M && M.loc && istype(M.loc, /room))
			var/room/R = M.loc
			var/list/Exits = R.getExitNames()
			for(var/Exit in Exits)
				if(inputOps.short2full(T,Exit,1))
					M.Movement(Exit)
					return 1
		return 0

	Parse(string, mob/user = usr)
		var/Temp_Parser/temp = new(user)
		var/tokens[] = Tokenize(string)
		for(var/Command/C in Commands)
			temp.New(user)
			if(C.Match(tokens, temp) && C.Allow(user))
				C.Allowed(user)
				var/X = Process(user, C, temp.matches)
				C.Postprocess(user)
				del temp
				return X
		if(!checkMoveCommand(string, user))
			Error(user, string, tokens)
			del temp
			return 0

	Error(user, string, tokens)
		sendTxt("I don't understand what you mean with [string].\n", user, DT_MISC, 0)
		return 1

var/Parser/MUD/parser
service/parser
	name = "Parser"

	bootHook()
		if(!parser)
			parser = new/Parser/MUD()
		return 1

	haltHook()
		if(parser) parser = null
		return 1

atom/ParseMatch(Name, multi = 1, ignorecase = 1)
	if(!Name) return 0
	if(!__keywords) return 0
	return __keywords.match(Name, ignorecase, multi)
