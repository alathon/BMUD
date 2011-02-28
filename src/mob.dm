mob
	// Prevent mobs from bumping
	density = 0

	var
		// The direction this mob left in
		// Used for things like room.exitMessage
		direction

	// Setter for gender. Makes sure gender isn't set to an invalid
	// value
	proc/setGender(n)
		if(n in list("male","female","neuter"))
			gender = n

	// Is this mob in-game? Used by various stuff
	// when looping through f.ex. client mobs, to
	// figure out if they're in the game or not.
	proc/isIngame()
		return 1 // TODO: Subtype with return 0 for /mob/login
