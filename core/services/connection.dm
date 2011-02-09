/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\core\services\connection.dm

Handles newly connected clients, deleted clients and various related issues.
When a client connects, the following happens:

1) Client type is determined (DetermineClientType())
2) The client is slept until the service_controller is running
3) If no connection manager exists, default behavior is returned.
4) If one is, the following occurs:
    I) Is usr defined?
        a. Yes, call connection_manager.RedirectClient(src,usr) to reconnect a player
        b. No, create a new login mob and call connection_manager.RedirectClient(src) to
           send them to the character manager.


*/
client
	script = "<STYLE>BODY {font: monospace; background: #000001; color: green}</STYLE>"
	view   = "21x11"

	var/tmp
		client_type = CLIENT_TELNET
		client_os   = UNIX
		logging_out  = 0

client
	New()
		DetermineClientType()
		while(!service_controller || !service_controller._running)
			sleep(1)

		Log("New [client_type == CLIENT_DS ? "DS":"Telnet"] Client connection from [address ? address : "localhost"]", EVENT_CONNECTION_NEW)
		if(!connection_manager)
			Log("No connection manager.", EVENT_CONNECTION_NEW)
			return ..()

		if(usr)
			connection_manager.RedirectClient(src, usr)
		else
			var/mob/login/M = new()
			M.key = src.key
			M.loc = null
			Log("Created mob with key [src.key]", EVENT_CONNECTION)
			connection_manager.RedirectClient(src)

	Del()
		if(connection_manager)
			connection_manager.RemOnlineClient(src)

			if(mob) mob.Logout()
		Log("Client disconnecting from [address].", EVENT_CONNECTION_DEL)
		return ..()

client/proc
	DetermineClientType()
		if(!findtext(src.key, ".")) // DS
			client_type = CLIENT_DS

		if(client_type == CLIENT_TELNET)
			return 1

		while(1)
			var/q = input(src, "Are you running DreamSeeker from Windows? (Answer yes or no please) \[Yes]") as text
			if(Short2Full(q,"no"))
				break
			else if(Short2Full(q,"yes") || !q)
				client_os = MS_WINDOWS
				break

	Logout()
		logging_out = 1
		var/logout_delay = 0 // for now

		sleep(logout_delay)

		if(logging_out)
			var/mob/Old = src.mob
			if(!Old)
				return connection_manager.RedirectClient(src)

			if(Old.loc)
				for(var/mob/M in oview(5, Old))
					SendTxt("[Old.GetName()] logs out.", M, DT_MISC)
			var/mob/M = new()
			M.key = src.key
			M.loc = null
			del Old
			return connection_manager.RedirectClient(src)

	ExitGame()
		src << "Bye!"
		del src

mob
	Logout(save = 1)
		if(!connection_manager)
			return ..()

		connection_manager.RemOnlinePlayer(src)

		if(!key) // Null key. Player switch
			if(!save) return ..()

			del src // Save the mob here too

		if(client)
			if(client.logging_out)
				del src // Save the mob here too
			else
				connection_manager.AddLinkdeadPlayer(src)

		else
			connection_manager.AddLinkdeadPlayer(src)

	Login()
		if(connection_manager)
			connection_manager.AddOnlinePlayer(src)
			if(src in connection_manager.linkdead_players) // Linkdead player.
				connection_manager.RemLinkdeadPlayer(src)
				if(loc)
					SendTxt("[src.GetName()] returns from linkdeath.", loc, DT_MISC, 0)
					return 1
				else
					SendTxt("TODO: Relocate player to start location!", src, DT_MISC, 0)
					return 0

			else // New mob connection
				. = ..()

mob/login // mob/login prototype used to keep a player, while they're browsing the login menu.
	Login()
	Logout()
		del src

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

	var/tmp/list
		online_players[0]
		online_clients[0]
		linkdead_players[0]

	proc
		AddLinkdeadPlayer()
		AddOnlinePlayer()
		AddOnlineClient()
		RemLinkdeadPlayer()
		RemOnlinePlayer()
		RemOnlineClient()
		RedirectClient()

	AddOnlinePlayer(mob/M)
		if(!M || !istype(M, /mob)) return 0
		if(online_players && M in online_players) return 0
		if(!online_players) online_players = new()
		online_players += M
		Log("Added online player: [M.GetName()]", EVENT_CONNECTION)
		return 1

	AddLinkdeadPlayer(mob/M)
		if(!M || !istype(M, /mob)) return 0
		if(linkdead_players && M in linkdead_players) return 0
		if(!linkdead_players) linkdead_players = new()
		linkdead_players += M
		Log("Added linkdead player: [M.GetName()]", EVENT_CONNECTION)
		spawn(MAX_LINKDEAD_TIME)
			if(M in linkdead_players) // still linkdead. Bootum
				RemLinkdeadPlayer(M)
				M.Logout(1)
		return 1

	AddOnlineClient(client/C)
		if(!C || !istype(C, /client)) return 0
		if(online_clients && C in online_clients) return 0
		if(!online_clients) online_clients = new()
		online_clients += C
		Log("Added online client: [C.key]/[C.address ? C.address : "localhost"]", EVENT_CONNECTION)
		return 1

	RemOnlineClient(client/C)
		if(!C || !istype(C, /client) || !online_clients || !(C in online_clients)) return 0
		online_clients -= C
		Log("Removed online client: [C.key]/[C.address ? C.address : "localhost"]", EVENT_CONNECTION)
		if(!length(online_clients)) online_clients = null
		return 1

	RemOnlinePlayer(mob/M)
		if(!M || !istype(M, /mob) || !online_players || !(M in online_players)) return 0
		online_players -= M
		Log("Removed online player: [M.GetName()]", EVENT_CONNECTION)
		if(!length(online_players)) online_players = null
		return 1

	RemLinkdeadPlayer(mob/M)
		if(!M || !istype(M, /mob) || !linkdead_players || !(M in linkdead_players)) return 0
		linkdead_players -= M
		Log("Removed linkdead player: [M.GetName()]", EVENT_CONNECTION)
		if(!length(linkdead_players)) linkdead_players = null
		return 1

	RedirectClient(client/C, mob/existing)
		AddOnlineClient(C)
		if(existing) // This is a 'fresh' client connection. Reconnect if possible
			if(existing.client)
				var/a = IO.Input("Someone is already logged into that character. Do you want to replace them?", C, answer = ANSWER_YESNO)
				if(a && C)
					Log("Reconnected client: [C.key] to mob: [existing.GetName()]", EVENT_CONNECTION)
					SendTxt("Reconnecting...", C, DT_MISC, 0)
					existing.Login()
					return existing
				else
					if(C) SendTxt("Goodbye, then!", C, DT_MISC, 0)
					return null

			else // No client on that character already.
				Log("Reconnected client: [C.key] to mob: [existing.GetName()]", EVENT_CONNECTION)
				SendTxt("Reconnecting...", C, DT_MISC, 0)
				existing.Login()
				return existing

		else
			if(!character_manager)
				return 1
			else
				character_manager.CharacterMenu(C)
