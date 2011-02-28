/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Gr�nbaum, 2007

bmud2\core\booting.dm

booting.dm supplies the only, central world/New().
*/


world/New()
	DEFAULT_SERVICE_FILE = "cfg/services.cfg"
	log_manager = new()
	if(log_manager.Load())
		log_manager.Loaded()
		service_controller = new()
	else
		del world
