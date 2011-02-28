room
	parent_type = /area

	var
		// Room exits for typical directions.
		room/north
		room/south
		room/east
		room/west

	// Message to display to room before A enters.
	proc/enterMessage(atom/A)
		if(ismob(A))
			var/mob/M = A
			sendTxt("\a [M.getName()] enters", contents, DT_MISC)

	// Message to display to room after A has left.
	proc/exitMessage(atom/A)
		if(ismob(A))
			var/mob/M = A
			sendTxt("\a [M.getName()] leaves[M.direction? " [M.direction]":""]", contents, DT_MISC)


	// Allows you to prevent A from leaving/entering by returning 0.
	// Effects related to the atom itself are checked by the
	// atom BEFORE a call to Move() (and thus Exit) is made.
	// As such, Exit() and Enter() should only check room-related
	// effects (Such as locked doors, magical effects, or w/e)
	Exit(atom/A)
		return 1

	Enter(atom/A)
		enterMessage(A)
		return 1

	// Entered() and Exited() are called after something has
	// done just that. Ideal place to f.ex. show the room description.
	Entered(atom/A, atom/OldLoc)
		if(ismob(A))
			var/mob/M = A
			M.direction = ""
			if(M.client)
				sendTxt(describeTo(M), M, DT_MISC)
		return 1

	Exited(atom/movable/O)
		exitMessage(O)
		return 1

	// Returns a reference to an exit based on a text string.
	proc/hasExit(d)
		if(d in list("north","south","east","west"))
			return src.vars[d]

	// Provides a colored text with exits, for room descriptions.
	proc/exits2text()
		. = ""
		var/list/L = getExitNames()
		if(isnull(L)) return "#rNone#n"
		. = "#r"
		var/i = length(L)
		for(var/a in L)
			if(a == L[i])
				. += "[a]#n"
			else
				. += "[a], "

	// Provides a plain list of exit names as text
	proc/getExitNames()
		var/list/L = new()
		if(istype(src.north)) L += "north"
		if(istype(src.south)) L += "south"
		if(istype(src.east)) L += "east"
		if(istype(src.west)) L += "west"

		// TODO: Include exits contained in the 'contents' of the room.
		// TODO: Implement exit 'objects'
		return L

	// Provides a list of exits as room references
	proc/getExits()
		var/list/L = new()
		if(istype(src.north)) L += src.north
		if(istype(src.south)) L += src.south
		if(istype(src.east)) L += src.east
		if(istype(src.west)) L += src.west

		// TODO: Include exits contained in the 'contents' of the room.
		// TODO: Implement exit 'objects'
		return L
