var/inputOptions/inputOps = new()

inputOptions
	var
		ANSWER_TYPE_TEXT = 1
		ANSWER_TYPE_NUM = 2
		ANSWER_TYPE_ANY = 3
		ANSWER_TYPE_LIST = 4

		ANSWER_ERROR_INPUT = "(@)*#()KOASJDLKAJ"
		ANSWER_ERROR_MISMATCH = "!()@*KALSJDDJKL"
		ANSWER_BACK = "back"
		ANSWER_EXIT = "exit"

		list/exclude_vars = list("type", "parent_type", "vars")

Input
	var
		client/_target
		_allow_mult
		_question
		_answer_type
		_loop_time
		_input
		_inputSet
		_parse_err
		_delete_on_err
		_case_sensitive
		_timeout
		_password
		_confirm
		_confirm_now
		_callback
		_callback_obj
		list/_answers
		_default_answer

	proc
		_blockForInput()
			var/prev_input
			while(1)
				SendTxt(_question, _target, DT_MISC)
				while(!_inputSet) sleep(_loop_time)
				if(_confirm)
					if(_confirm_now && prev_input != _input)
						_parse_err = inputOps.ANSWER_ERROR_MISMATCH
					else
						if(!_confirm_now)
							_confirm_now = TRUE
							_question = _confirm
							_inputSet = FALSE
							prev_input = _input
							_input = null
							continue
						else
							break

				return _input

		// Should set _inputSet = false and give a valid error in _parse_err
		// if the user enters something not valid for this type of input.
		// Otherwise, should set _inputSet = true and return the input
		_parseInput(n)
			if(!n && _default_answer) n = _default_answer
			while(1)
				. = 1 // Assume input is correct
				if(_callback)
					. = call(_callback_obj, _callback)(_target, n)

				if(!.)
					_parse_err = inputOps.ANSWER_ERROR_INPUT
					break

				if(_answer_type == inputOps.ANSWER_TYPE_LIST)
					if(!_case_sensitive)
						n = lowertext(n)

					// Todo: Add support for the autocomplete option
					if(!(n in _answers + list("back","exit")))
						SendTxt("Invalid answer.", _target, DT_MISC, 0)
						_parse_err = inputOps.ANSWER_ERROR_INPUT
						break

				else if(_answer_type == inputOps.ANSWER_TYPE_NUM)
					if(n != "back" && n != "exit")
						n = text2num(n)
						if(!n)
							_parse_err = inputOps.ANSWER_ERROR_INPUT
							break

				_inputSet = TRUE
				return n

			SendTxt(_question, _target)

		getInput()
			if(_parse_err)
				. = _parse_err
				if(_delete_on_err)
					_target._target = null
					spawn(5) del src
				else
					_inputSet = FALSE
					_input = null
					_parse_err = null

			else
				. =  _input

		receiveInput(n)
			_parse_err = null
			if(!_allow_mult && _inputSet) return

			var/p = _parseInput(n)
			if(_inputSet)
				_input = p

	New(client/D,question, answer_type=inputOps.ANSWER_TYPE_ANY,
		list/answers, loop_time=2,
		allow_mult=FALSE, case_sensitive=FALSE,
		delete_on_err=FALSE, timeout=0,
		confirm=FALSE, password=FALSE)

		if(!D || !question) del src

		D._target = src
		src._target = D
		if(istype(question, /InputSettings))
			var/InputSettings/I = question
			for(var/V in I.vars)
				if(!(V in inputOps.exclude_vars)) src.vars[V] = I.vars[V]
		else
			src._question = question
			src._answer_type = answer_type
			src._loop_time = loop_time
			src._allow_mult = allow_mult
			src._timeout = timeout
			src._delete_on_err = delete_on_err
			src._case_sensitive = case_sensitive
			src._answers = answers
			src._password = password
			src._confirm = confirm
			src._confirm_now = FALSE

		src._inputSet = FALSE
		_blockForInput()

/*

Usecase 1:

spawn()
	var/Input/I = new Input(player, "Do you like this new method?")
	// the creation of Input blocks until it has an answer. So now we have one.
	// This input type (ANSWER_TYPE_ANY) can't error in any way, so we don't have to
	// check for that.
	var/answer = I.getInput()

Usecase 2:

// Here, with a list the player may enter something not in the list.
// In such a case, the result of getInput() is ERROR_INPUT, so you can
// handily loop over that to keep asking the player until they answer properly.

spawn()
	var/answer = ERROR_INPUT
	while(answer == ERROR_INPUT)
		var/Input/I = new Input(player, "Do you like this new method? (Y/N)", ANSWER_TYPE_LIST, list("y","n"))
		answer = I.getInput()

Usecase 3:

// Using an InputSettings object to set settings.
// Same as above, except also case-insensitive.

spawn()
	var/InputSettings/IS = new InputSettings()
	IS.setQuestion("Do you like this new method? (Y/N)")
	IS.setAnswerType(ANSWER_TYPE_LIST)
	IS.setAnswerList(list("y","n"))
	IS.setCaseSensitive(false)

	var/answer = ERROR_INPUT
	while(answer == ERROR_INPUT)
		var/Input/I = new Input(player, IS)
		answer = I.getInput()

Usecase 4:

// Input objects will automatically delete themselves after sending a getInput()
// with ERROR_INPUT as the return value. This can be prevented, if you want, by
// specifying the 'delete_on_error' setting.

// This changes the loop construct slightly. Its only there to theoretically allow
// you to keep the Input object around, if you should so desire.
// This does, in theory, allow you to re-use the same Input() object. The Input object
// will reset state to 'factory defaults', upon a getInput().

spawn()
	var/InputSettings/IS = new InputSettings()
	IS.setQuestion("Do you like this new method? (Y/N)")
	IS.setAnswerType(ANSWER_TYPE_LIST)
	IS.setAnswerList(list("y","n"))
	IS.setCaseSensitive(false)
	IS.setDeleteOnError(false)

	var/answer
	var/Input/I = new Input(player, IS)
	while(1)
		answer = I.getInput()
		if(answer != ERROR_INPUT) break
		I.initAgain()

Total options list:

'question=string' (InputSettings.setQuestion(string)) - Sets the question to be asked of the player.
'answer_type=ANSWER_TYPE_ANY|ANSWER_TYPE_LIST|ANSWER_TYPE_NUMBER' (InputSettings.setAnswerType(same options)) - Sets the answer type.
'answer_list=list' (InputSettings.setAnswerList(list)) - Sets the list of possible answers, for ANSWER_TYPE_LIST.
'case_sensitive=bool' (InputSettings.setCaseSensitive(bool)) - Sets whether case of an answer should matter.
'delete_on_err=bool' (InputSettings.setDeleteOnError(bool)) - Sets whether to delete the input on an error, or reset it to mint condition.
'auto_complete=bool' (InputSettings.setAutoComplete(bool)) - With list form, allows you to enter partial match.
'timeout=number' (InputSettings.setTimeout(number)) - Will force the return of an answer after number milliseconds.
'allow_mult=bool' (InputSettings.setAllowMult(bool)) - If set to true, will allow user to 'overwrite' the value of the input until the game gets to
	dealing with the input. False by default, so once a player has entered something for an input, thats it.
*/


