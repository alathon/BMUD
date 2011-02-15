inputParser
	proc
		parse(Input/I, n)

	answer_any
		parse(Input/I, n)
			I.__input = n

	answer_list
		parse(Input/I, n)
			var/match = FALSE
			for(var/a in I.__answers)
				match = cmptext(a,n)
				if(match)
					n = a
					break
			if(!match)
				return new/inputError("Invalid answer.")
			else
				I.__input = n
				return

	answer_yesno
		parse(Input/I, n)
			if(Short2Full(n,"yes",1))
				I.__input = "yes"
				return
			else if(Short2Full(n,"no",1))
				I.__input = "no"
				return
			else
				return new/inputError("Must answer yes or no.")

	answer_num
		parse(Input/I, n)
			var/t2n = text2num(n)
			if("[n]" == "[t2n]")
				I.__input = t2n
				return
			else
				return new/inputError("Not a number.")
