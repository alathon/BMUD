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


// /client additions for connecting
client/New()
	determineClientType()
	while(!service_controller || !service_controller._running)
		sleep(1)

	Log("New client connected from [address]", EVENT_CONNECTION_NEW)

	if(character_manager)
		character_manager.newClientConnection(src)

client/Del()
	if(connection_manager)
		connection_manager.remOnlineClient(src)
	..()

client/proc/determineClientType()
	if(!findtext(src.key, "."))
		src << "We're sorry, but DreamSeeker client connections are not supported"
		src << "Please connect using a real telnet client :)"
		del src // No DS connections


var/_service/connection_manager/connection_manager
_service/connection_manager
	name = "ConnectionManager"
	dependencies = list("IO")

	Loaded()
		if(!connection_manager) connection_manager = src
		..()

	Unloaded()
		if(connection_manager == src) connection_manager = null
		..()

	var/list
		__online_clients = new()
		__linkdead_players = new()

	proc
		getOnlinePlayers()
			var/list/L = new()
			for(var/client/C)
				if(C.mob)
					L += C.mob
			return L

		getOnlineClients()
			. = new/list()
			for(var/client/C) . += C

		getLinkdeadPlayers()
			return __linkdead_players

		addOnlineClient(client/C)
			Log("Added online client: [C.key]/[C.address ? C.address : "localhost"]", EVENT_CONNECTION)

		remOnlineClient(client/C)
			Log("Removed online client: [C.key]/[C.address ? C.address : "localhost"]", EVENT_CONNECTION)

		addLinkdeadPlayer(mob/M) // TODO:
		remLinkdeadPlayer(mob/M) // TODO:
