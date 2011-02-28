
/*

A form is a sequence of _questions. Upon 'submission', the form
will signal that it is ready to be read. It can also signal that
the user has exited the form, in a variety of different ways (Chose to exit, disconnected).

The API is as follows:

spawn()
	var/form/F = new()
	F.AddQuestion(id="some_id", InputSettings object)
	F.begin(client)
	if(F.isComplete())
		// Start reading values from F.
		var/some_var = F.GetAnswer("some_id")
	else
		return // Bad form.

The form works by allowing the user to opt to go back to the previous step at any time by typing 'back', or
exit the form completely by typing 'exit'. As such, 'back' and 'exit' are not legal _answers to any _questions
asked by a form.

questions are asked in the order they are added, and can be fetched by form.getAnswer(id), where id is the id of
the question. If no id is provided, an incremental numerical ID is assigned. Mixing the two is a bad idea, and why
would you want to be doing that?
*/
form
	var
		__state
		__exitMethod
		__allowExit = TRUE
		__allowBack = TRUE
		__allowForward = TRUE
		__currentQuestion = 1

		list/__answers = new()
		list/__questions = new()

	New()
		__state = formOps.STATE_READY

	proc

		copy()
			var/form/F = new()
			var/list/exclude = list("type",
					"parent_type", "tag", "vars",
					"__answers", "__questions")

			for(var/a in F.vars)
				if(a in exclude) continue
				if(istype(src.vars[a],/list))
					var/list/L = src.vars[a]
					F.vars[a] = L.Copy()
				else
					F.vars[a] = src.vars[a]

			for(var/a in __questions)
				var/Input/idx = __questions[a]
				F.addQuestion(a, idx.copy())

			return F

		__allAnswered()
			if(!length(__answers)) return FALSE

			for(var/a = 1 to length(__answers))
				var/idx = __answers[a]
				if(__answers[idx] == inputOps.INPUT_BAD)
					return FALSE
			return TRUE

		__findMissingQuestion()
			var/idx = __currentQuestion+1
			if(idx > length(__answers)) idx = 1

			for(var/a = idx to length(__answers))
				var/aidx = __answers[a]
				if(__answers[aidx] == inputOps.INPUT_BAD) return a
			return 0

		getAnswer(key)
			if(key in __answers) return __answers[key]

		addQuestion(key, Input/I)
			if(__allowExit)
				I.setAllowExit(TRUE)
			if(__allowBack)
				I.setAllowBack(TRUE)
			if(__allowForward)
				I.setAllowForward(TRUE)

			__questions += key
			__questions[key] = I
			__answers += key
			__answers[key] = inputOps.INPUT_BAD

		isComplete()
			return (__allAnswered() && __exitMethod == formOps.EXIT_COMPLETE)

		begin(client/C)
			if(__state != formOps.STATE_READY) return
			if(!C) return

			__state = formOps.STATE_WORKING
			while(__state == formOps.STATE_WORKING)
				if(!C)
					__state = formOps.STATE_DONE
					__exitMethod = formOps.EXIT_DISCONNECT
					return formOps.EXIT_DISCONNECT

				var/idx = __questions[__currentQuestion]
				var/Input/I = __questions[idx]
				var/answer = I.getInput(C)

				if(answer == inputOps.INPUT_EXIT)
					__state = formOps.STATE_DONE
					__exitMethod = formOps.EXIT_EXIT
					return formOps.EXIT_EXIT
				else if(answer == inputOps.INPUT_BACK)
					if(!__currentQuestion)
						if(C) sendTxt("You cannot go back any further.", C, DT_MISC, 0)
						continue
					__currentQuestion--
					continue
				else if(answer == inputOps.INPUT_FORWARD)
					if(__currentQuestion == length(__questions))
						if(C)
							sendTxt("There are no other questions to answer.", C, DT_MISC, 0)
						continue
					__currentQuestion++
					continue

				idx = __answers[__currentQuestion]
				__answers[idx] = answer
				if(__allAnswered())
					break

				// Next question.
				__currentQuestion = __findMissingQuestion()

			__state = formOps.STATE_DONE
			__exitMethod = formOps.EXIT_COMPLETE
			return __exitMethod
