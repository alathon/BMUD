/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\core\services\logging.dm

This file deals with logging mechanisms.

The /log service constructs and manages /log's. Logs are used
when you want large amounts of data regularly written to files.
A log must have a service_level below or equal to the log managers
service_level, in order for logging to occur. This check happens in
log_manager.Input().

If LOGGING isn't defined, the Log() procedure is cleared, for effeciency
reasons.

*/

#define LOGGING
#ifdef LOGGING
proc
	Log(data, data_type)
		if(log_manager)
			log_manager.Input(data, data_type)
#else
proc
	Log(data, data_type)
#endif

var/_service/log_manager/log_manager
_service/log_manager
	name = "LogManager"

	New(fake = 0)
		if(!fake)
			text2file("\[[time2text(world.timeofday, "MM/DD/YY hh:mm:ss")]] DT:\[[EVENT_NEWDATUM]] Created datum: [src.type] (ref=\ref[src])", "[DIR_LOGS]creation[ENDING_LOG]")

	var/tmp/list/logs[0]
	var/tmp/service_level = 3

	proc
		AddLog()
		RemLog()
		IsLog()
		Input()

	Input(data, data_type)
		for(var/l in logs)
			var/log/L = logs[l]
			if(L.CanLog(data_type) && L.service_level <= src.service_level)
				L.Input(data, data_type)

	Loaded()
		AddLog("proc", list(EVENT_PROC, EVENT_PROCFAIL), 1)
		AddLog("sys", list(EVENT_SYSINFO), 1)
		AddLog("creation", list(EVENT_NEWDATUM, EVENT_DELDATUM), 1)
		AddLog("general", list(EVENT_GENERAL), 2)
		AddLog("commands", list(EVENT_COMMAND, EVENT_BADCOMMAND), 2)
		AddLog("connection", list(EVENT_CONNECTION_NEW, EVENT_CONNECTION_DEL, EVENT_CHARACTER, EVENT_CONNECTION), 1)
		AddLog("service", list(EVENT_SERVICE), 1)
		AddLog("chat", list(EVENT_CHAT), 2)
		..()

	Unloaded()
		Input("Shutting down log manager", EVENT_PROC)
		if(log_manager == src) log_manager = null
		for(var/log/L in logs)
			RemLog(L.name)
		..()

	AddLog(lname, log_list, sl = 2)
		if(!lname || !istype(log_list, /list)) return 0

		if(IsLog(lname)) return 0

		var/log/L = new()
		L.name = lname
		L.file_write = lname
		L.log_list = log_list
		L.service_level = sl

		if(fexists("[DIR_LOGS][lname][ENDING_LOG]"))
			text2file("\n", "[DIR_LOGS][lname][ENDING_LOG]")

		if(!logs) logs = new()
		logs += lname
		logs[lname] = L
		Input("Adding log for event types: [list2text(L.log_list, ",")] ([L.name])", EVENT_PROC)
		return L

	RemLog(lname)
		var/log/L = IsLog(lname)
		if(!L) return 0
		Input("Removing log: [lname]", EVENT_PROC)
		L.KillGraceful()
		logs -= L
		if(!logs.len) logs = null
		return 1

	IsLog(lname)
		return (logs && (lname in logs))

log
	var
		interval = 10
		file_write = null
		buffer = ""
		list/log_list[0]
		name = ""
		service_level = 0

	proc
		Input()
		Buffer2File()
		CanLog()
		FormatData()
		KillGraceful()
		PeriodicDump()

	New()
		..()
		spawn()
			PeriodicDump()

	KillGraceful()
		del src

	PeriodicDump()
		set background = 1
		while(istext(file_write))
			if(buffer)
				Buffer2File()
			sleep(interval)

	Input(data, data_type)
		if(!data || !data_type) return 0
		var/formatted = FormatData(data, data_type)
		buffer += "[formatted]\n"

	Buffer2File()
		if(file_write)
			text2file(copytext(buffer,1,length(buffer)), "[DIR_LOGS][file_write][ENDING_LOG]")
		buffer = ""

	CanLog(d)
		return (log_list ? (d in log_list) : null)

	FormatData(data, data_type, data_level)
		return "\[[time2text(world.timeofday, "MM/DD/YY hh:mm:ss")]] DT:\[[data_type]] [data]"


// The log analyst is a tool to analyze logs.
_service/log_analyst
	name = "LogAnalyst"
	dependencies = list("LogManager")

	proc
		WhatsAlive()

	WhatsAlive()
		var/list/creations = text2list(file2text(DIR_LOGS + "creation" + ENDING_LOG), "\n")

		var/list/return_list = list("created", "deleted")

		return_list["created"] = list()
		return_list["deleted"] = list()

		for(var/a in creations)
			var/list/L
			var/start_bracket = findtext(a, "(")
			var/end_bracket   = findtext(a, ")")
			if(!start_bracket) continue

			var/data_type = text2num(copytext(a, 25, 26))
			var/datum_name = copytext(a, 43, start_bracket - 1)
			var/datum_key  = copytext(a, start_bracket+1, end_bracket)

			if(data_type == EVENT_NEWDATUM)
				L = return_list["created"]
			else
				L = return_list["deleted"]

			L += list2params(list("key" = datum_key, "name" = datum_name))

		. = "Number of datums alive, according to logs:\n"
		// Now see whats alive that isn't dead.
		for(var/a in return_list["created"])
			if(!(a in return_list["deleted"]))
				var/list/A = params2list(a)
				. += "Name: [A["name"]] Key: [A["key"]]\n"
		. += "\n"
