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
