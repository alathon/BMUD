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
				if(C.mob.isIngame())
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
