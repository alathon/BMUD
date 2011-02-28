mob
	var
		// The direction this mob left in
		// Used for things like room.exitMessage
		direction

	proc
		// Is this mob ingame? 
		isIngame()
			return 1 // Everyone's ingame right now.
					 // TODO: Subtype for /mob/login

mob
	density = 0

	// This function refreshes keywords based on various
	// things such as name, race, etc.
	__updateKeywords()
		__keywords.setKeywords(list(lowertext(name),"mob"))

	// Setters to set various things
	proc/setGender(n)
		if(n in list("male","female","neuter"))
			gender = n

	setName(n)
		if(!n) return
		name = uppertext(copytext(n, 1, 2))+copytext(n, 2)
		__updateKeywords()
		Log("TODO: Write log message for this([__LINE__])",
			EVENT_CHARACTER)
