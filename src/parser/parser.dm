/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\core\parser\parser.dm

Modifies and implements a Parser object, from AbyssDragon's Parser library.
The entry-point into the parser is client/Command().
*/

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
			Log("[(src.mob ? src.mob.name : src.ckey)]: [T]", EVENT_BADCOMMAND)

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
_service/parser
	name = "Parser"

	Loaded()
		if(!parser)
			parser = new/Parser/MUD()
		..()

	Unloaded()
		if(parser) parser = null
		..()

atom/ParseMatch(Name, multi = 1, ignorecase = 1)
	if(!Name) return 0
	if(!__keywords) return 0
	return __keywords.match(Name, ignorecase, multi)
