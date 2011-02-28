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
