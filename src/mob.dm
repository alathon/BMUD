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
