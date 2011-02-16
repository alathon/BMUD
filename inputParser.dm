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
		SendTxt(txt, trg)

inputOptions
	var
		INPUT_EXIT = "exit"
		INPUT_FORWARD = "next"
		INPUT_BACK = "back"

inputParser/default
	answer_list
		key = "list"
		parse(Input/I, n)
			if(inputOps.isEmpty(n))
				if(I.__defaultAnswer)
					n = I.__defaultAnswer
				else if(!I.__allowEmpty)
					return new/inputError("Invalid chocie")

			var/match = FALSE
			var/list/L = I.__answers.Copy()
			if(I.__allowExit) L += inputOps.INPUT_EXIT
			if(I.__allowBack) L += inputOps.INPUT_BACK
			if(I.__allowForward) L += inputOps.INPUT_FORWARD

			for(var/a in L)
				world << "[a] in L"
				if(I.__autoComplete)
					match = inputOps.short2full(n, a, I.__ignoreCase)
				else
					if(I.__ignoreCase)
						match = cmptext(n,a)
					else
						match = cmptextEx(n,a)
				if(match)
					world << "match"
					n = a
					break
			if(!match)
				return new/inputError("Invalid choice.")
			else
				I.__input = n
				return

	answer_yesno
		key = "yesno"
		parse(Input/I, n)
			if(inputOps.short2full(n,"yes", 1)) // Always ignore case
				I.__input = "yes"
				return
			else if(inputOps.short2full(n,"no",1)) // always ignore case
				I.__input = "no"
				return
			else
				while(1)
					if(I.__allowExit && cmptext(n,inputOps.INPUT_EXIT))
						break
					else if(I.__allowBack && cmptext(n,inputOps.INPUT_BACK))
						break
					else if(I.__allowForward && cmptext(n,inputOps.INPUT_FORWARD))
						break
					return new/inputError("Must answer yes or no.")
				I.__input = n
				return

	answer_num
		key = "num"
		parse(Input/I, n)
			if(I.__allowExit && cmptext(n,inputOps.INPUT_EXIT) || I.__allowBack && cmptext(n,inputOps.INPUT_BACK) || I.__allowForward && cmptext(n,inputOps.INPUT_FORWARD))
				I.__input = n
				return
			if(!n || (inputOps.whitespace(n) == length(n)))
				return new/inputError("Not a number.")
			var/t2n = text2num(n)
			if("[n]" == "[t2n]")
				I.__input = t2n
				return
			else
				return new/inputError("Not a number.")
