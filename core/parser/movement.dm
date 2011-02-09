mob/proc
	Movement(d)
		var/room/R = src.loc
		if(R.IsExit(d))
			var/room/NewR = R.exits[d]
			src.Move(NewR)
		else
			if(client)
				SendTxt("You can't move there.", src, DT_MISC, 0)

/*
Command/MUD/movement
	category = "\[0;33mMovement\[0m"
	northwest
		format = "'northwest'|'nw'|'northw'"
		Process(mob/user)
			..()
			user.Movement("northwest")

	northeast
		format = "'northeast'|'ne'|'northe'"
		Process(mob/user)
			..()
			user.Movement("northeast")

	southeast
		format = "'southeast'|'se'|'southe'"
		Process(mob/user)
			..()
			user.Movement("southeast")

	southwest
		format = "'soutwest'|'sw'|'southw'"
		Process(mob/user)
			..()
			user.Movement("southwest")

	north
		format = "'north'|'n'|'forward'"
		Process(mob/user)
			..()
			user.Movement("north")

	south
		format = "'south'|'s'|'back'"
		Process(mob/user)
			..()
			user.Movement("south")
	east
		format = "'east'|'e'|'right'"
		Process(mob/user)
			..()
			user.Movement("east")
	west
		format = "'west'|'w'|'left'"
		Process(mob/user)
			..()
			user.Movement("west")
*/
