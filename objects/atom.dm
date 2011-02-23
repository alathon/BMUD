atom
	movable
		var/size = 1

	var
		list/keywords // TODO: Replace with textMatcher datum

	proc
		keywords()
		getName()
		getDesc()
		describeSelf()

	getName()
		return "\a [src][suffix]"

	getDesc()
		return desc

	keywords()
		return keywords

atom/ParseMatch(Name, multi = 1, ignorecase = 1)
	if(!Name) return 0
	if(!keywords || !length(keywords)) return 0

	var/list/match = keywords.Copy()

	if(isobj(src)) 
		var/obj/O = src
		if(O.getPlural()) match += O.getPlural()

	if(!ignorecase) ignorecase = 1 // Always ignore case. <--

	if(ignorecase)
		Name = lowertext(Name)
		for(var/a in match) a = lowertext(a)

	if(!multi)
		if(!match.Find(Name))
			return FALSE
	else
		var/found_it = FALSE
		for(var/Example in match)
			if(inputOps.short2full(Name, Example, ignorecase))
				found_it = TRUE
		if(!found_it)
			return FALSE
	return TRUE


