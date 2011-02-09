/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\core\services\service_controller.dm

The service controller loads up all services, starts them up and keeps
track of them. The services.cfg file is used in conjunction to figure out
what services to load, and what services not to. See Alathon.Services library
for more information.
*/

_service
	Loaded()
		Log("Service [src.name] loaded", EVENT_SERVICE)

	Unloaded()
		Log("Service [src.name] unloaded", EVENT_SERVICE)

_service_controller
	excluded_services = list(/_service, /_service/auto, /_service/log_manager)

	GenerateIndex()
		Log("Generating service index.", EVENT_SERVICE)
		. = 0
		// Create all services, to generate the service index.
		for(var/S in typesof(/_service) - /_service - /_service/auto)
			var/_service/C = new S(!findtext("[S]", "/auto"))
			service_index += C.name
			service_index[C.name] = C.type
			if(!istype(C, /_service/auto))
				C.Del(1)

	LoadServiceFile()
		Log("Loading service configuration file.", EVENT_SERVICE)
		return ..()

	Shutdown()
		if(!_running) return 0

		Log("Shutting down service controller", EVENT_SERVICE)
		service_index = null // Clear the service index.

		for(var/S in services) // Unload all services
			UnloadService(services[S])
			RemService(S)
		_running = 0
		Log("Service controller shut down", EVENT_SERVICE)

	Startup()
		if(_running) return 0

		if(!log_manager)
			world.log << "SYSTEM WARNING:: The Log manager has not been created. Aborting!"
			return 0

		Log("Service Controller starting up", EVENT_SERVICE)
		// Generate the service index
		GenerateIndex()

		// Load up auto services
		for(var/S in services)
			LoadService(services[S])

		// Now, load everything else needed.
		LoadServiceFile()
		_running = 1
		Log("Service Controller started up", EVENT_SERVICE)