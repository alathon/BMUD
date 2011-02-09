/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Gr�nbaum, 2007

bmud2\core\_constants.dm

constants.dm defines a series of consts and #defines, used around the code. They are centralized here
for referencial purpose.
*/
var
	const
		TOKEN_SYMBOL = "$" // Used by IO.TranslateTokens(). Determines the key character to prepend tokens with.

		// These are used by the service manager and login system. Determines the state of the service manager and thus the world.
		SERVICE_SHUTDOWN = -1
		SERVICE_BOOTING = 0
		SERVICE_STARTUP = 1
		SERVICE_RUNNING = 2

		// Used by IO.Input()
		ANSWER_TEXT = 1
		ANSWER_NUM = 2
		ANSWER_MOBREF = 3
		ANSWER_OBJREF = 4
		ANSWER_ROOMREF = 5
		ANSWER_ZONEREF = 6
		ANSWER_PLAYERREF = 7
		ANSWER_NPCREF = 8
		ANSWER_LIST_NUM = 9
		ANSWER_LIST = 10
		ANSWER_YESNO = 11

		// Log-related bits.
		// Syslog
		EVENT_PROC = 1
		EVENT_PROCFAIL = 2

		EVENT_NEWDATUM = 4
		EVENT_DELDATUM = 5
		EVENT_SYSINFO  = 6
		EVENT_GENERAL  = 7

		EVENT_CLIENTSEE = 8 // SendTxt() to client.
		EVENT_CLIENTDO  = 9 // Input() to client

		// Used by connection handler
		EVENT_CONNECTION_NEW = 10
		EVENT_CONNECTION_DEL = 11
		EVENT_CHARACTER      = 12
		EVENT_CONNECTION     = 17

		EVENT_SERVICE = 13 // Service-related events.

		EVENT_CHAT = 14

		EVENT_BADCOMMAND = 15
		EVENT_COMMAND = 16

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

		// Used to determine client type
		CLIENT_TELNET = 1
		CLIENT_DS     = 2

		// Used by menu.dm
		MENU_BACK = "-1@@BACK@@-1"
		MENU_REPEAT = "-1@@REPEAT@@-1"

		// Used by the service manager.
		FILE_SERVICE_INDEX = "./services.cfg"

		// used by connection handler
		MAX_LINKDEAD_TIME = 1200