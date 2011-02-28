/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\objects\trace.dm

The trace object attaches itself to a datum, and works like a temporary logfile for that datum. Each logfile can
have participants, which can choose to filter out certain message types based on the data type of the message.
*/

atom
	recieveText(T, data_type, colorize = 0)
		if(tracer) tracer.Input(T, data_type)
		return T

datum
	var/tmp/trace/tracer = null

var/list/tracers

trace
	var/tmp
		list/participants
		datum/target
		buffer = ""
		interval = 100
		trace_file = ""


	proc
		AddParticipant()
		RemParticipant()
		IsParticipant()
		FormatInfo()
		Input()
		AlertParticipants()
		PeriodicDump()
		Buffer2File()

	New(datum/T, F)
		. = ..()
		if(!T || !istype(T, /datum)) return 0
		if(T.tracer) return 0 // Theres already a tracer on that datum
		if(!tracers) tracers = new()

		tracers += src
		target = T
		target.tracer = src
		if(F) trace_file = F

	Del()
		tracers -= src
		if(!tracers.len) tracers = null
		if(target) target.tracer = null
		. = ..()

	AddParticipant(client/C)
		if(!C || !istype(C,/client)) return 0
		if(participants && (C in participants || C == target || (C.mob && C.mob == target))) return 0

		if(!participants) participants = new()
		participants += C

	RemParticipant(client/C)
		if(!participants || !(C in participants)) return 0

		participants -= C
		if(!length(participants)) participants = null

	IsParticipant(client/C)
		return (C in participants)

	Buffer2File()
		if(trace_file)
			text2file(copytext(buffer,1,length(buffer)), DIR_TRACES + trace_file + ENDING_TRACE)
		buffer = ""

	PeriodicDump()
		set background = 1
		while(trace_file)
			if(buffer)
				Buffer2File()
			sleep(interval)

	Input(data, data_type)
		AlertParticipants(data, data_type)
		if(trace_file)
			buffer += data


	AlertParticipants(txt, dt)
		if(participants)
			for(var/client/C in participants)
				if(is_set(dt, C.trace_exclude)) continue
				sendTxt(txt, C, 0)

client/var/trace_exclude = 0 // Exclude nothing by default
