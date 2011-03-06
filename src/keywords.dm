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
	__keywords.setKeywords(list(name,"mob"))

obj/__updateKeywords()
	var/list/L = new()
	L += src.getBaseName()
	if(src.getCount() > 1) L += src.getPlural()
	__keywords.setKeywords(L)
