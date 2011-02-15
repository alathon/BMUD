inputFormatter
	proc
		notifyQuestion(Input/I)
		notifyError(Input/I)

	// Default just prints 'as-is'
	default
		notifyQuestion(Input/I)
			world << I.getQuestion()
		notifyError(Input/I)
			var/inputError/E = I.getError()
			world << E.error
