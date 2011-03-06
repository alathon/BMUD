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

This logger allows you to add log files via log_manager.addType(type_name). The
typename should correspond with a constant in src/constants.dm, which is the type
you provide the Log(msg, type) command. Example:

Log("Logging to general!", EVENT_GENERAL)

Logs are stored in buffers and flushed periodically by a scheduler. Each type has its
own /Event/Timer/, which is a recurring timer from Stephen001.eventscheduler.

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
		for(var/a in __logs)
			flushLog(a)
		for(var/a in __logs)
			remType(a)

		if(log_manager == src) log_manager = null
		return 1
