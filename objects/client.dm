client
	var
		menu/current_menu = null

	proc
		Percieve()
		LookRoom()
		LookObj()
		LookMob()
		LookInvalid()

	Percieve(target)
		if(!target) // Percieve self
			src << "You percieve yourself... ! /TestMsg"
			return 0

		else
			if(istype(target, /mob))
				return LookMob(target)
			else if(istype(target, /obj))
				return LookObj(target)
			else
				return LookInvalid(target)

	LookMob(mob/M)
		SendTxt(M.describeSelf(src), src)
		return 1

	LookObj(obj/O)
		SendTxt(O.describeSelf(src), src)
		return 1

	LookInvalid(T)
		SendTxt("You look around you, but can't seem to find [T].", src, 0)
		return 1

	proc/SetMenu(menu/M)
		if(!M) return 0

		current_menu = M
		M.GetInput(src)

client/New()
	DetermineClientType()
	while(!service_controller || !service_controller._running)
		sleep(1)

	Log("New client connected from [address]", EVENT_CONNECTION_NEW)

	if(character_manager)
		character_manager.newClientConnection(src)

client/Del()
	if(connection_manager)
		connection_manager.remOnlineClient(src)
	..()

client/proc/DetermineClientType()
	if(!findtext(src.key, "."))
		src << "We're sorry, but DreamSeeker client connections are not supported"
		src << "Please connect using a real telnet client :)"
		del src // No DS connections


