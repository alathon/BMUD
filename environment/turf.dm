/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\environment\turf.dm

Various procedures for turfs, to broadcast entry/exit, display the map to telnet users,
and some other things for DS compliance (Like statpanel formatting).
*/
area
	var
		move_factor = 1

turf
	Del()
	New()

	Enter(mob/O)
		if(ismob(O))
			if(src.density) return 0
		return 1

	Entered(mob/O)
		if(ismob(O))
			if(O.client && O.client.client_type != CLIENT_DS)
				O.Look()
		return 1

	desc = "Undefined description here."

	var
		display_bg   = ""
		move_factor  = -1

	proc
		DescribeExits()
		DescribeContents()
		GetMoveFactor()
		FormatForStatpanel()

	FormatForStatpanel(atom/ref) // DS compliance
		. = ""
		for(var/atom/A in src)
			if(ismob(A) && A != ref)
				. += "[A.DescribeSelf(src)] is here\n"
			if(isobj(A))
				. += "[A.DescribeSelf(src)]\n"
		. += " "

	GetMoveFactor()
		if(move_factor >= 0) return move_factor

		var/area/A = loc
		while(A && !isarea(A)) A = A.loc

		return A.move_factor

	DescribeExits()
		. += "Obvious exits: #z"
		for(var/turf/T in orange(1, src))
			if(!T.density) . += "[directions["[get_dir(src, T)]"]] "
		if(length(.) == 17) . += "None!"
		. += "#n"

	DescribeContents(atom/ref)
		. += "\n"
		for(var/atom/A in src)
			if(ismob(A) && A != ref)
				. += "[A.DescribeSelf(src)] is #Yhere#n\n"
			if(isobj(A))
				. += "[A.DescribeSelf(src)]\n"
