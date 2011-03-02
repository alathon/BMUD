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
