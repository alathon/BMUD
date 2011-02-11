
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

question
	New(id, InputSettings/settings)
		if(!id || !istype(settings, /InputSettings))
			CRASH("Attempt to create invalid question.")

		src.id = id
		src.settings = settings

	var
		InputSettings/settings
		Input/_input
		callback_func
		answer
		id

	proc
		/* Initiates the input request to the client. */
		ask(client/C)
			answer = inputOps.ANSWER_ERROR_INPUT
			_input = new(C, settings)
			answer = _input.getInput()
			//if(answer == "back") answer = formOps.ANSWER_BACK
			//else if(answer == "exit") answer = formOps.ANSWER_EXIT

		getAnswer()
			. = answer
			del _input


var/formOptions/formOps = new()
formOptions
	var/const
		EXIT_EXIT = -1
		EXIT_DISCONNECT = 0
		EXIT_SUCCESS = 1

form
	var
		_done_asking = FALSE
		_idc=0
		list/_questions // _questions are indexed by the question 'id'.
		list/_answers
		_exit_reason

	proc
		addQuestion(id, InputSettings/I)
			if(!istype(I, /InputSettings))
				CRASH("Non-InputSettings object passed to form.addQuestion() for id:[id]") // Todo: replace with Log

			if(!id) id = ++_idc

			if(!_questions) _questions = new/list()

			var/question/Q = new(id, I)
			_questions += id
			_questions[id] = Q

		_setupExit()
			_questions.Cut()
			_idc = 0
			_done_asking = TRUE

		getAnswer(id)
			if(_answers && id in _answers) return _answers[id]

		getExitReason()
			return _exit_reason

		isComplete()
			return _done_asking && _exit_reason == formOps.EXIT_SUCCESS

		begin(client/C)
			if(!_questions)
				CRASH("Attept to ask about empty form") // Todo: replace with Log
			if(!_answers) _answers = new()

			var/i = 1
			_done_asking = FALSE
			while(length(_answers) < length(_questions))
				var/idx = _questions[i]
				var/question/Q = _questions[idx]
				var/answer = inputOps.ANSWER_ERROR_INPUT
				while(answer == inputOps.ANSWER_ERROR_INPUT)
					if(!C)
						_setupExit()
						_exit_reason = formOps.EXIT_DISCONNECT

					Q.ask(C)
					if(!C)
						_setupExit()
						_exit_reason = formOps.EXIT_DISCONNECT
						return
					answer = Q.getAnswer(C)

				if(answer == inputOps.ANSWER_BACK)
					if(i == 1) // First question. Backing out here is not allowed.
						continue
					i--
					continue
				else if(answer == inputOps.ANSWER_EXIT)
					_setupExit()
					_exit_reason = formOps.EXIT_EXIT
					return
				else if(answer == inputOps.ANSWER_ERROR_MISMATCH)
					if(!C)
						_setupExit()
						_exit_reason = formOps.EXIT_DISCONNECT
						return
					SendTxt("Invalid input. Try again.", C, DT_MISC, 0)
					continue
				else
					_answers[Q.id] = answer
					i++
			_done_asking = TRUE
			_exit_reason = formOps.EXIT_SUCCESS
