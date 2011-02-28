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

