InputSettings
	var
		_allow_mult=FALSE
		_question
		_answer_type
		_loop_time=2
		_delete_on_err=FALSE
		_case_sensitive=FALSE
		_timeout=0
		_password=FALSE
		_confirm
		_confirm_now=FALSE
		_callback
		_callback_obj
		list/_answers
		_default_answer

	New()
		_answer_type = inputOps.ANSWER_TYPE_ANY
		..()

	proc
		setAllowMult(n)
			_allow_mult = n

		setQuestion(n)
			_question = n

		setAnswerType(n)
			_answer_type = n

		setDeleteOnError(n)
			_delete_on_err = n

		setCaseSensitive(n)
			_case_sensitive = n

		setTimeout(n)
			_timeout = n

		setPassword(n)
			_password = n

		setConfirm(n)
			_confirm = n

		setCallback(o,n)
			_callback = n
			_callback_obj = o

		setAnswerList(n)
			_answers = n

		setDefaultAnswer(n)
			_default_answer = n
