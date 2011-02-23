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


