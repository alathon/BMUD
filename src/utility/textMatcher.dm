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


textMatcher
	New(list/L)
		if(istype(L)) setKeywords(L)

	var
		list/__keywords=new()
		__ignoreCase = TRUE
		__partial = TRUE

	proc
		setIgnorecase(n)
			__ignoreCase = n

		setPartial(n)
			__partial = n

		setKeywords(list/L)
			if(!istype(L, /list)) L = args
			if(istype(L, /list))
				__keywords = L

		match(text, ignoreCase = __ignoreCase, partial = __partial)
			for(var/a in __keywords)
				if(partial)
					if(inputOps.short2full(text,a,ignoreCase)) return a
				else
					if(ignoreCase)
						if(cmptext(text,a)) return a
					else
						if(cmptextEx(text,a)) return a
			return FALSE
