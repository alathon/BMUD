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


/* Generally speaking, the following methods of description exist:

- All atoms can describe themselves to another atom, via the
  atom.describeTo() procedure
- All atoms have a 'name' variable. However, you should instead use
  the atom.getName(), atom.getFullName() procedures unless you need
  just the raw name.
- To figure out whether an atom matches a text string, use the
  atom.matches(textstring) procedure. It will return the match if
  there is one.
- All atoms have a '__desc' variable, intended to be similar to the
  'longdesc' variable most MUDs have. This would be a personal
  biography for players, a longer description of how an obj looks,
  or similar. However, to *read* the description, use atom.getDesc(),
  as the atom may have dynamic properties which influence the
  description.
*/

atom/proc/describeTo(atom/A)
atom/proc/getDesc()
atom/var/__desc

// Used by various things to determine whether the mob
// has visibility of the atom A.
// Should be in some combat-related folder, when one
// is around.
mob/proc/canSee(atom/A)
	return (see_invisible >= A.invisibility)

room/describeTo(mob/M)
	if(!ismob(M)) return "Not implemented"

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
			. += "[m.describeTo(src)]\n"
		for(var/obj/O in contents)
			if(!M.canSee(O)) continue
			. += "[O.describeTo(src)]\n"
		. = copytext(.,1,length(.)) // Cut the last \n


obj/describeTo(atom/A)
	if(!A) return

	if(istype(A, /room))
		if(__count > 1)
			return "[getName()] lie here[suffix]"
		else
			return "[getName()] lies here"
	else if(istype(A, /mob))
		return "[getName()][suffix]"
	else
		return "Not implemented yet!"

mob/describeTo(atom/A)
	if(!A) return
	if(istype(A, /room))
		return getName()
	else if(istype(A, /mob))
		return src.getDesc(A)
	else
		return "Not implemented yet."


