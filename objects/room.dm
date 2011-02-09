/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\environment\room.dm

Rooms are children of area, and work like 'locations' in a sense. This file contains
general procedures to enable interaction with rooms.
*/
mob/var/direction = ""

room
	parent_type = /area

	var
		list/exits = null

	proc
		RemoveSelf()
		AddExit()
		RemExit()
		Exits()
		IsExit()
		ConnectsTo()
		Exits2Text()
		EnterMsg()
		ExitMsg()

	EnterMsg(atom/A)
		if(!A) return 0
		if(ismob(A))
			var/mob/M = A
			SendTxt("\a [M.GetName()] enters", contents, DT_MISC)
		return 1

	ExitMsg(atom/A)
		if(!A) return 0
		if(ismob(A))
			var/mob/M = A
			SendTxt("\a [M.GetName()] leaves[M.direction ? " [M.direction]" : ""]", contents, DT_MISC)
		return 1

	Exit(atom/A) // A attempting to exit src.
		return 1

	Enter(atom/A)
		EnterMsg(A)
		return 1

	Entered(atom/A, atom/OldLoc)
		if(ismob(A))
			var/mob/M = A
			M.direction = ""
			if(M.client)
				SendTxt(DescribeSelf(M), M, DT_MISC)
		return 1

	Exited(atom/movable/O)
		ExitMsg(O)
		return 1

	Entered(atom/movable/Obj,atom/OldLoc)
		if(ismob(Obj))
			var/mob/M = Obj
			if(M.client)
				SendTxt(DescribeSelf(M), M, DT_MISC)
		return 1

	AddExit(list/L)
		if(!exits) exits = new

		if(!istype(L, /list))
			L = list("[args[1]]" = args[2])

		for(var/a in L)
			if(a in exits) return 0

			// TODO: Check if L[a] is really a room. If not, try to act as if its
			// a room reference. If that won't resolve, deny.
			exits += a
			exits[a] = L[a]

		return 1

	RemExit(list/L)
		if(!exits) return 0

		if(!istype(L, /list))
			L = list("[args[1]]")

		for(var/a in L)
			if(a in exits) exits -= a

		if(!length(exits)) exits = null
		return 1

	Exits2Text()
		. = ""
		var/list/L = Exits()
		if(isnull(L)) return "#rNone#n"
		. = "#r"
		var/i = length(L)
		for(var/a in L)
			if(a == L[i])
				. += "[a]#n"
			else
				. += "[a], "

	Exits()
		return ((exits && length(exits)) ? exits : null)

	IsExit(name)
		return (exits && (name in exits) && (istype(exits[name], /room)))

	ConnectsTo(room/R)
		for(var/a in exits)
			if(exits[a] == R || exits[a] == R._uid) return R
		return null

	DescribeSelf(mob/M)
		if(!ismob(M)) return "Unfinished feature: Room.DescribeSelf() to other than mob!"

		// Room Name, Room Description
		. = ""
		. += "\n\[[src.GetName()]\]"
		. += "\n"
		. += "[src.GetDesc()]\n"

		// Room Exits
		. += "Obvious exits: [src.Exits2Text()]"

		// Room Contents
		if(length(contents))
			. += "\n\n"
			for(var/mob/m in contents)
				if(M == m || !M.CanSee(m)) continue
				. += "[m.DescribeSelf(src)]\n"
			for(var/obj/O in contents)
				if(!M.CanSee(O)) continue
				. += "[O.DescribeSelf(src)]\n"
			. = copytext(.,1,length(.)) // Cut the last \n






// Interaction between turfs and rooms use teleporters.
// PHASED OUT
room/teleporter
	New()
		if(destination && !istype(destination, /atom))
			if(findtext(destination, ",")) // X,Y,Z coordinates
				var/X = copytext(destination, 1, 2)
				var/Y = copytext(destination, 3, 4)
				var/Z = copytext(destination, 5, 6)
				var/turf/T = locate(X,Y,Z)
				if(isturf(T))
					destination = T
			else
				var/split = findtext(destination, "|")
				if(!split) return 0

				var/cluster_name = copytext(destination, 1, split)
				var/room_name    = copytext(destination, split+1)
				var/room/R = room_manager.GetRoom(cluster_name, text2num(room_name))
				if(istype(R, /room))
					destination = R

	Entered(atom/A)
		return 1

	Enter(atom/movable/A)
		if(istype(destination, /atom))
			A.Move(destination)

	var
		atom/destination

turf/teleporter
	New()
		if(destination && !istype(destination, /atom))
			var/first_comma = findtext(destination, ",")
			if(first_comma) // X,Y,Z coordinates
				var/X = copytext(destination, 1, first_comma)
				var/second_comma = findtext(destination, ",", first_comma+1)
				var/Y = copytext(destination, first_comma+1, second_comma)
				var/Z = copytext(destination, second_comma+1)
				var/turf/T = locate(X,Y,Z)
				if(isturf(T))
					destination = T
			else
				var/split = findtext(destination, "|")
				if(!split) return 0

				var/cluster_name = copytext(destination, 1, split)
				var/room_name    = copytext(destination, split+1)
				var/room/R = room_manager.GetRoom(cluster_name, text2num(room_name))
				if(istype(R, /room))
					destination = R

	Entered(atom/A)
		return 1

	Enter(atom/movable/A)
		if(istype(destination, /atom))
			A.Move(destination)

	var
		atom/destination


