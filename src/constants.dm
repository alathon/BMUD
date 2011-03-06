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

var
	const
		TOKEN_SYMBOL = "$" // Used by IO.TranslateTokens(). Determines the key character to prepend tokens with.

		// These are used by the service manager and login system. Determines the state of the service manager and thus the world.
		SERVICE_SHUTDOWN = -1
		SERVICE_BOOTING = 0
		SERVICE_STARTUP = 1
		SERVICE_RUNNING = 2

		// Log-related bits.
		EVENT_CONNECTION	= "connection"
		EVENT_SYS			= "sys"
		EVENT_COMMAND		= "command"
		EVENT_GENERAL		= "general"
		EVENT_CHAT			= "chat"

		LOG_FLUSH_INTERVAL = 50 // Flush log every 5s, +- 1s

		// Trace stuff
		DT_MISC = 1
		DT_PRIV = 2
		DT_SYSINFO = 4
		DT_CHAT = 8
		DT_MENU = 16

		// Directory stuff
		DIR_LOGS = "./logs/"
		DIR_TRACES = "./traces/"

		ENDING_LOG = ".log"
		ENDING_TRACE = ".trc"
