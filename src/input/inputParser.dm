/*******************************************************************************
 * BMUD ("this program") is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 ******************************************************************************/

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

inputParser/default
	answer_list
		getAnswers()
			var/list/L = I.__answers.Copy()
			if(I.__allowExit) L += inputOps.INPUT_EXIT
			if(I.__allowBack) L += inputOps.INPUT_BACK
			if(I.__allowForward) L += inputOps.INPUT_FORWARD
			return L

	answer_numbered_list
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
