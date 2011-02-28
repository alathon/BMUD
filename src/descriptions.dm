/* Keywords are used to match an atom. Altering the name of
an atom triggers re-building the keyword list, as should anything
else that can potentially be tied to the keyword list. Remember to call
__updateKeywords() in those cases. */

atom
	var
		tmp/textMatcher/__keywords=new()

	proc/__updateKeywords()
		__keywords.setKeywords(list(name))

	proc/setName(n)
		if(!n) return
		name = n
		__updateKeywords()

	proc/getFullName()
		return "\a [src][suffix]"

	proc/getName()
		return "\a [src]"

	proc/getDesc()
		return desc

	proc/matches(n)
		return __keywords.match(n)

// Update keywords
mob/__updateKeywords()
	__keywords.setKeywords(list(lowertext(name),"mob"))

obj/__updateKeywords()
	var/list/L = new()
	L += src.getBaseName()
	if(src.getCount() > 1) L += src.getPlural()
	__keywords.setKeywords(L)

// Set name

// Capitalize first letter.
mob/setName(n)
	if(!n) return
	name = uppertext(copytext(n, 1, 2))+copytext(n, 2)
	__updateKeywords()
	Log("TODO: Write log message for this([__LINE__])",
		EVENT_CHARACTER)

/* describeTo() is used to describe the object to another object. */
atom/proc/describeTo(atom/A)

// Used by various things to determine whether the mob
// has visibility of the atom A.
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


