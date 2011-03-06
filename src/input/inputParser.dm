// Add support for 'back'/'exit'/'forward'
Input
	proc
		setAllowExit(n)
			if(__state != inputOps.STATE_READY) return
			__allowExit = n

		setAllowBack(n)
			if(__state != inputOps.STATE_READY) return
			__allowBack = n

		setAllowForward(n)
			if(__state != inputOps.STATE_READY) return
			__allowForward = n

	var
		__allowExit = FALSE
		__allowBack = FALSE
		__allowForward = FALSE

inputFormatter
	send(txt,trg)
		sendTxt(txt, trg)

inputOptions
	var
		INPUT_EXIT = "exit"
		INPUT_FORWARD = "next"
		INPUT_BACK = "back"
/*
inputParser/default
	answer_list
		getAnswers()
			var/list/L = I.__answers.Copy()
			if(I.__allowExit) L += inputOps.INPUT_EXIT
			if(I.__allowBack) L += inputOps.INPUT_BACK
			if(I.__allowForward) L += inputOps.INPUT_FORWARD
			return L

	answer_yesno
		key = "yesno"
		parse(Input/I, n)
			. = ..()
			if(istype(., /inputError)) return .

			while(1)
				if(I.__allowExit && cmptext(n,inputOps.INPUT_EXIT))
					break
				else if(I.__allowBack && cmptext(n,inputOps.INPUT_BACK))
					break
				else if(I.__allowForward && cmptext(n,inputOps.INPUT_FORWARD))
					break
				return inputOps.getError(inputOps.ERROR_YESNO)
			I.__input = n
			return

	answer_num
		key = "num"
		parse(Input/I, n)
			. = ..()
			if(istype(., /inputError)) return .

			while(1)
				if(I.__allowExit && cmptext(n,inputOps.INPUT_EXIT))
					break
				else if(I.__allowBack && cmptext(n,inputOps.INPUT_BACK))
					break
				else if(I.__allowForward && cmptext(n,inputOps.INPUT_FORWARD))
					break
				return inputOps.getError(inputOps.ERROR_NOTNUM)
			I.__input = n
			return
*/
