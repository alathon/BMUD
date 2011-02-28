/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\core\services\io.dm

Contains the input/output related procedures between client and server.

sendTxt()
---------
Use sendTxt(txt, targets, data_type, colorize) to send text to a player. Always use
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
	proc/recieveText(T, data_type, colorize = 1)
		if(mob)
			mob.recieveText(T, data_type, colorize)
			if(mob.tracer) mob.tracer.Input(T, data_type)
		else
			if(colorize && color_manager)
				T = color_manager.Colorize(T)
			src << T
		return T

atom/proc/recieveText()

mob
	recieveText(txt, data_type, colorize = 0)
		if(client)
			if(colorize && color_manager)
				txt = color_manager.Colorize(txt)
			src << txt
		..()

proc
	sendTxt(txt, targets, data_type = DT_MISC, colorize = 1)
		if(IO)
			return IO.sendTxt(txt, targets, data_type, colorize)

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
		sendTxt()


	sendTxt(txt, list/targets, data_type = DT_MISC, color = 1)
		if(!targets) return 0
		if(targets && !istype(targets, /list)) targets = list(targets)

		for(var/a in targets)
			if(!istype(a, /atom) && !istype(a, /client)) continue
			a:recieveText(txt, data_type, color)
