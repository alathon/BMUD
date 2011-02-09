/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\core\booting.dm

booting.dm supplies the only, central world/New().
*/

world/New()
	log_manager = new()
	if(log_manager.Load())
		log_manager.Loaded()
		service_controller = new()
	else
		del world
