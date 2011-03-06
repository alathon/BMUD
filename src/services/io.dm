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


client
	proc/recieveText(T, data_type, colorize = 1)
		if(mob)
			if(mob.tracer) mob.tracer.Input(T, data_type)
		if(colorize && color_manager)
			T = color_manager.Colorize(T)
		src << T
		return T

atom/proc/recieveText()

mob
	recieveText(txt, data_type, colorize = 0)
		if(client) client.recieveText(txt, data_type, colorize)

proc
	sendTxt(txt, targets, data_type = DT_MISC, colorize = 1)
		if(IO)
			return IO.sendTxt(txt, targets, data_type, colorize)

var/service/io/IO
service/io
	name = "IO"

	bootHook()
		if(!IO) IO = src
		return 1

	haltHook()
		if(IO == src) IO = null
		return 1

	proc
		sendTxt()


	sendTxt(txt, list/targets, data_type = DT_MISC, color = 1)
		if(!targets) return 0
		if(targets && !istype(targets, /list)) targets = list(targets)

		for(var/a in targets)
			if(!istype(a, /atom) && !istype(a, /client)) continue
			a:recieveText(txt, data_type, color)
