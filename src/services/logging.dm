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


/*
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
			log_manager.Log(data, data_type)
#else
proc
	Log(data, data_type)
#endif

// Recurring timer for logs.
Event/Timer/LogEvent
	New(sched, freq, dt)
		..(sched, freq)
		src.data_type = dt

	fire()
		..()
		if(log_manager)
			log_manager.flushLog(data_type)

	var
		data_type = ""

var/service/logMan/log_manager
service/logMan
	name = "LogManager"

	var
		EventScheduler/scheduler = new()
		list/__logs = new()
		list/__logEvents = new()

	proc/flushLog(t)
		if((t in __logs) && (__logs[t] != ""))
			text2file(__logs[t], "[DIR_LOGS][t][ENDING_LOG]")
			__logs[t] = ""

	proc/addType(t)
		if(t in __logs) return
		__logs += t
		__logs[t] = ""
		__logEvents += t
		var/Event/Timer/LogEvent/L = new(scheduler,
										LOG_FLUSH_INTERVAL, t)
		__logEvents[t] = L
		scheduler.schedule(L, LOG_FLUSH_INTERVAL)

	proc/remType(t)
		var/Event/E = __logEvents[t]
		__logs -= t
		__logEvents -= t
		scheduler.cancel(E)
		del E

	proc/Log(data, data_type)
		if((data_type in __logs) && length(data))
			var/nline = ""
			if(__logs[data_type] != "") nline = "\n"
			var/logmsg	 = "[nline]\[[time2text(world.realtime,"hh:mm:ss")]\]"
			logmsg		+= " [data]"
			__logs[data_type] += logmsg

	proc/logMsg(t)
		Log(t, EVENT_SYS)

	bootHook()
		if(!log_manager) log_manager = src
		world.log = file("logs/world.log")
		mud.setLogger(src)
		addType(EVENT_CONNECTION)
		addType(EVENT_SYS)
		addType(EVENT_COMMAND)
		addType(EVENT_GENERAL)
		addType(EVENT_CHAT)
		Log("---Booting game---", EVENT_SYS)
		scheduler.start()
		return 1

	haltHook()
		Log("Shutting down log manager", EVENT_SYS)
		if(log_manager == src) log_manager = null
		for(var/a in __logs)
			remType(a)
		return 1
