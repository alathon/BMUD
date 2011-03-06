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

// List of services
boot/getServices()
	return list("/service/logMan"
			  , "/service/io"
			  , "/service/colorMan"
			  , "/service/connectionMan"
			  , "/service/roomMan"
			  , "/service/charMan"
			  , "/service/parser")

// Helper to keep client in limbo until we're ready
proc/blockUntilRunning(client/C)
	while(!mud || mud.getState() != BOOT_STATE_RUNNING)
		sleep(1)

// Global 'mud' object
var/boot/mud
world/New()
	mud = new()
	mud.setState(BOOT_STATE_BOOT)
