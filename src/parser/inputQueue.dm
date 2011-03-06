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

// Sleep queue for inputs.
Input
	proc
		wakeUp()
			if(__state == inputOps.STATE_SLEEP)
				__state = inputOps.STATE_READY

		sleepNow()
			__state = inputOps.STATE_SLEEP

client
	var
		queue/lifo/__inputQueue = new()

	queueInput(Input/I)
		if(!istype(I)) return
		if(__target) // This queue interrupts
					 // TODO: Give Input's a priority to decide whether
					 // TODO: to interrupt or not.
			__target.sleepNow()
			__inputQueue.push(__target)
			__target = I
		else
			__target = I

	dequeueInput(Input/I)
		if(I == __target)
			__target = __inputQueue.pop()
			if(__target)
				__target.wakeUp()

		else
			__inputQueue.remove(I)

	hasInput(Input/I)
		if(__target == I || __inputQueue.contains(I)) return TRUE
		return FALSE

