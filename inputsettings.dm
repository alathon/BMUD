InputSettings
	var
		_allow_mult = FALSE
		_question
		_answer_type = ANSWER_TYPE_ANY
		_loop_time = 2
		_parse_err
		_delete_on_err = FALSE
		_case_sensitive = FALSE
		_timeout = 0
		_confirm
		_confirm_now = FALSE
		_password = FALSE
		_callback
		_callback_obj
		list/_answers
		_default_answer

	proc
		setDefaultAnswer(n)
			_default_answer = n

		setQuestion(n)
			_question = n

		setAnswerType(n)
			_answer_type = n

		setLoopTime(n)
			_loop_time = n

		setCallback(obj, n)
			_callback = n
			_callback_obj = obj

		setDeleteOnError(n)
			_delete_on_err = n

		setCaseSensitive(n)
			_case_sensitive = n

		setTimeout(n)
			_timeout = n

		setAnswerList(n)
			_answers = n

		setConfirm(n)
			_confirm = n

		setPassword(n)
			_password = n
