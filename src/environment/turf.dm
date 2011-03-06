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
