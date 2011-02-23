/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\environment\room.dm

Rooms are children of area, and work like 'locations' in a sense. This file contains
general procedures to enable interaction with rooms.
*/
room
	parent_type = /area

	var
		room/north
		room/south
		room/east
		room/west

	proc
		enterMessage(atom/A)
			if(ismob(A))
				var/mob/M = A
				sendTxt("\a [M.getName()] enters", contents, DT_MISC)

		exitMessage(atom/A)
			if(ismob(A))
				var/mob/M = A
				sendTxt("\a [M.getName()] leaves[M.direction? " [M.direction]":""]", contents, DT_MISC)


	Exit(atom/A) // A attempting to exit src.
		return 1

	Enter(atom/A)
		enterMessage(A)
		return 1

	Entered(atom/A, atom/OldLoc)
		if(ismob(A))
			var/mob/M = A
			M.direction = ""
			if(M.client)
				sendTxt(describeSelf(M), M, DT_MISC)
		return 1

	Exited(atom/movable/O)
		exitMessage(O)
		return 1

	proc/hasExit(d)
		if(d in list("north","south","east","west"))
			return src.vars[d]

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

	proc/getExitNames()
		var/list/L = new()
		if(istype(src.north)) L += "north"
		if(istype(src.south)) L += "south"
		if(istype(src.east)) L += "east"
		if(istype(src.west)) L += "west"

		// TODO: Include exits contained in the 'contents' of the room.
		// TODO: Implement exit 'objects'
		return L

	proc/getExits()
		var/list/L = new()
		if(istype(src.north)) L += src.north
		if(istype(src.south)) L += src.south
		if(istype(src.east)) L += src.east
		if(istype(src.west)) L += src.west

		// TODO: Include exits contained in the 'contents' of the room.
		// TODO: Implement exit 'objects'
		return L

	describeSelf(mob/M)
		if(!ismob(M)) return "Unfinished feature: Room.DescribeSelf() to other than mob!"

		// Room Name, Room Description
		. = ""
		. += "\n\[[src.getName()]\]"
		. += "\n"
		. += "[src.getDesc()]\n"

		// Room Exits
		. += "Obvious exits: [src.exits2text()]"

		// Room Contents
		if(length(contents))
			. += "\n\n"
			for(var/mob/m in contents)
				if(M == m || !M.canSee(m)) continue
				. += "[m.describeSelf(src)]\n"
			for(var/obj/O in contents)
				if(!M.canSee(O)) continue
				. += "[O.describeSelf(src)]\n"
			. = copytext(.,1,length(.)) // Cut the last \n

