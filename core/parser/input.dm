// States:
// inputOps.STATE_READY 	<-- The input object is ready to begin accepting input.
// inputOps.STATE_INIT  	<-- The input object is setting up, and is not yet ready.
// inputOps.STATE_ACCEPT    <-- The input object is accepting input.
// inputOps.STATE_DONE		<-- The input object is done. (This and above state the same?)
// inputOps.STATE_ERROR		<-- Input was received, and bad.

Input
	// Constructor for test purposes ONLY
	New(q, ip, formatter)
		__state = inputOps.STATE_READY
		__parser = inputOps.getParser(ip) || inputOps.getParser("any")
		__formatter = inputOps.getFormatter(formatter) || inputOps.getFormatter("default")
		__question = q

	var
		list/__answers
		inputFormatter/__formatter
		inputParser/__parser
		client/__target
		inputError/__error
		__callback
		__callback_obj
		__loopTime = 2
		__input
		__state
		__answerType
		__question

	proc
		__errorUser()
			__formatter.notify(src, inputOps.FORMAT_ERROR)

		__questionUser()
			__formatter.notify(src, inputOps.FORMAT_QUESTION)

		__parseInput(n)
			var/inputError/E = __parser.parse(src, n)
			if(!istype(E, /inputError) && __callback)
				if(__callback_obj)
					E = call(__callback_obj, __callback)(__input)
				else
					E = call(__callback)(__input)

			if(istype(E, /inputError))
				__state = inputOps.STATE_ERROR
				__error = E
			else
				__state = inputOps.STATE_DONE

		__cleanAndExit()
			if(__target && __target.__target == src)
				__target.__target = null

			world << "DEBUG: Cleaning up and returning input"
			del src

		receiveInput(n)
			if(__state != inputOps.STATE_ACCEPT)
				world << "DEBUG: receiveInput([n]): Not ready to accept input"
				return

			__parseInput(n)

		getError()
			if(__error) return __error

		getQuestion()
			return __question

		getInput(client/C)
			if(__state != inputOps.STATE_READY)
				world << "DEBUG: getInput(): Not in STATE_READY, quitting"
				return // Generate error here ?

			__state = inputOps.STATE_ACCEPT
			__target = C
			C.__target = src
			world << "DEBUG: getInput(): __state = inputOps.STATE_ACCEPT"
			while(1)
				__questionUser()
				while(__state == inputOps.STATE_ACCEPT)
					sleep(__loopTime)

				if(__state == inputOps.STATE_DONE)
					break
				else if(__state == inputOps.STATE_ERROR)
					__errorUser()
					__state = inputOps.STATE_ACCEPT // return to accepting input.

			spawn()
				__cleanAndExit()
			return __input
