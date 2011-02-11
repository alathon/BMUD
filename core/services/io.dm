/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\core\services\io.dm

Contains the input/output related procedures between client and server.

SendTxt()
---------
Use SendTxt(txt, targets, data_type, colorize) to send text to a player. Always use
a colorize value of 0 if there is no need to color the string. By default, colorize is
set to 1.

IO.Input()
-------
Use Input(txt, client, answers, strict, case, default) to query for input from the player.

If answers is a list, an item from the list will be returned if one matches the input sent.
If strict is 1, a proper answer from the list MUST be supplied (Repeats the input).

If answers is ANSWER_TEXT, the response is sent directly back. This is the default

If answers is ANSWER_NUM, the returned value is a number. If strict is 1, the input sent
MUST be a number or the query is repeated.
*/

client
	proc/RecieveText(T, data_type, colorize = 1)
		if(colorize && color_manager)
			T = color_manager.Colorize(T, client_type)
		src << T
		if(mob && mob.tracer) mob.tracer.Input(T, data_type)
		return T

atom/proc/RecieveText()

mob
	RecieveText(txt, data_type, colorize = 0)
		if(client)
			if(colorize && color_manager)
				txt = color_manager.Colorize(txt, client.client_type)
			src << txt
		..()

proc
	SendTxt(txt, targets, data_type = DT_MISC, colorize = 1)
		if(IO)
			return IO.SendTxt(txt, targets, data_type, colorize)

var/_service/auto/io/IO
_service/auto/io
	name = "IO"

	Loaded()
		if(!IO) IO = src
		..()

	Unloaded()
		if(IO == src) IO = null
		..()

	proc
//		Input(txt,client/C,color_return)
		SendTxt()


	SendTxt(txt, targets, data_type = DT_MISC, color = 1)
		if(!targets) return 0
		var/list/T = list()
		if(istype(targets,/list))
			T = targets
		else
			T += targets

		for(var/a in T)
			if(!istype(a, /atom) && !istype(a, /client)) continue
			a:RecieveText(txt, data_type, color)
		T = null
/*
	Input(t, client/C, answers = ANSWER_TEXT, strict = 1, case = 0, default = "")
		if(!C)
			Log("Invalid arguments to IO.Input: ([t],[C],[answers],[strict],[case])", EVENT_PROCFAIL)
			return 0

		if(default) t += " \[[default]]"

		var/ct = C.client_os
		var/t_color = (color_manager ? color_manager.Colorize(t, C.client_type) : t)

		if(ct == MS_WINDOWS)
			SendTxt(t, C, DT_MISC, 1)

		var/input = input(C, (ct == MS_WINDOWS ? t : t_color)) as command_text

		if(default && !input) input = default

		if(!C) return 0

		var/log_ref = (C.mob ? C.mob.name : C.ckey)

		if(answers == ANSWER_TEXT)
			Log("[log_ref]: [input]", EVENT_CLIENTDO)

		else if(answers == ANSWER_NUM)
			var/numv = text2num(input)
			if(("[numv]" != "[input]") && strict)
				return Input(arglist(args))
			Log("[log_ref]: [input]", EVENT_CLIENTDO)
			input = numv

		else if(istype(answers, /list))
			for(var/a in answers)
				if(Short2Full(input, a, case))
					Log("[log_ref]: [input]", EVENT_CLIENTDO)
					return a

			if(strict)
				C << ""
				return Input(arglist(args))

			Log("[log_ref]: [input]", EVENT_CLIENTDO)
			return input

		else
			Log("Invalid answers type sent to Input(): [answers]", EVENT_PROCFAIL)
			CRASH("Invalid answers type sent to Input(): [answers]")

		return input
*/

