menuOptions
	proc
		getMenu(key)
			if(key in predefined) return predefined[key]

		getSubmenu(main, sub)
			if(main in predefined)
				var/menu/M = predefined[main]
				return M.findMenu(sub)

		addMenu(menu/M, key)
			predefined += key
			predefined[key] = M

		remMenu(key)
			if(key in predefined)
				predefined -= key

	var
		list/predefined = new()
		MENU_BACK   = "MENU_BACK@*()#ASJKLDsjkla()@"
		MENU_EXIT   = "MENU_EXITklASJKLOPWE564"
		MENU_REPEAT = "MENU_REPEATAKLSDJ@()~_)"
		MENU_NOT_READY = "MENU_NOT_READYlak^&HJK23"

var/menuOptions/menuOps = new()
menu
	New(list/keywords, displayText, menu/parent)
		if(keywords)
			if(istext(keywords)) keywords = list(keywords)
			src.__keywords = new(keywords)
			src.name = keywords[1]
		if(displayText)
			src.__displayText = displayText
		if(parent)
			parent.attach(src)
		__ready = TRUE

	var
		name = ""
		__ready = FALSE
		__allowExit = TRUE
		__allowBack = TRUE
		menu/parent
		list/children = new()
		__displayText
		textMatcher/__keywords
		form/__form
		callWrapper/__callback
		callWrapper/__inputCallback

	proc
		// For default callback mechanisms to navigate to menu's
		__callbackRootMenu()
			var/menu/M = parent
			while(1)
				if(M.parent) M = M.parent
				else break
			return M

		__callbackBack()
			return menuOps.MENU_BACK

		__callbackRepeat()
			return menuOps.MENU_REPEAT

		__callbackExit()
			return menuOps.MENU_EXIT

		// Performs an action related to a menu answer.
		// If a menu reference is passed, that menu is accessed.
		// If a menu navigation command (MENU_REPEAT, MENU_BACK, etc)
		// is passed, it is executed. Otherwise, an error is signalled
		__menuAnswer(client/C, i)
			if(!C) return
			if(istype(i, /menu))
				var/menu/M = i
				return M.ask(C)
			else if(i == menuOps.MENU_REPEAT)
				return ask(C)
			else if(i == menuOps.MENU_BACK)
				if(istype(parent)) return parent.ask(C)
				else return
			else if(i == menuOps.MENU_EXIT)
				return
			else if(i == inputOps.INPUT_BAD)
				return ask(C)
			else
				Log("Invalid menu answer [i]", EVENT_GENERAL)
				CRASH("Invalid menu answer [i]")

		// Perform action based on the exit code of a /form.
		// Will also make sure to verify with a form callback,
		// so that data can be pulled from a form that can then
		// either return the user to the menu or drop them out of
		// it by making sure the callback returns menuOps.MENU_EXIT
		__formExitCode(client/C, form/F, exit)
			if(!C) return
			if(exit == formOps.EXIT_DISCONNECT) return
			else if(exit == formOps.EXIT_EXIT)
				return ask(C) // Failure to complete = repeat menu
			else if(exit == formOps.EXIT_COMPLETE)
				if(istype(__callback))
					var/c = __callback.go(C, F)
					del F
					return __menuAnswer(C, c)
				else
					return __menuAnswer(C, menuOps.MENU_REPEAT)


		// Parses an answer. Should either return a menu command,
		// i.e. menuOps.MENU_BACK, a menu reference, or return bad
		// input with inputOps.INPUT_BAD
		__parse(answer)
			if(inputOps.isEmpty(answer))
				return menuOps.MENU_REPEAT

			if(answer == inputOps.INPUT_NOT_READY)
				return answer

			for(var/menu/M in children)
				if(M.match(answer)) return M

			if(__allowExit && inputOps.short2full(answer,"exit",1))
				return menuOps.MENU_EXIT
			if(__allowBack && inputOps.short2full(answer,"back",1))
				return menuOps.MENU_BACK

			return inputOps.INPUT_BAD

		__getReady(client/C)
			while(C && !__ready) sleep(1)

		defaultQuestionFormat()
			for(var/menu/M in children)
				. += "[M.getDisplayText()]\n"
			. += "Select an item from the menu\n"

		__getInput()
			var/inputQuestion = __inputQuestion()
			var/Input/I = new(inputQuestion)
			I.setAllowempty(TRUE)
			return I

		__inputQuestion()
			if(istype(__inputCallback))
				return __inputCallback.go(src)
			else
				return defaultQuestionFormat()

		setQuestionProc(callWrapper/W)
			if(istype(W) || isnull(W))__inputCallback = W

		findMenu(n)
			if(src.name == n) return src
			for(var/menu/M in children)
				. = M.findMenu(n)
				if(!isnull(.)) return .
			return null

		match(text)
			return __keywords.match(text)

		getDisplayText()
			return __displayText

		setForm(form/F, callWrapper/C)
			if(istype(F)) __form = F
			setCallback(C)

		setCallback(callWrapper/C)
			if(istype(C)) __callback = C

		ask(client/C)
			__getReady(C)
			if(!C) return
			// Menu that just links to a form.

			if(istype(__form))
				var/form/F = __form.copy()

				var/exit = F.begin(C)
				return __formExitCode(C, F, exit)
			else if(istype(__callback) && !length(children))
				var/c = __callback.go(C, src)
				return c

			// Real menu
			var/answer = inputOps.INPUT_BAD
			while(C && answer == inputOps.INPUT_BAD)
				var/Input/I = __getInput()
				answer = I.getInput(C)
				answer = __parse(answer)
				if(answer == inputOps.INPUT_NOT_READY)
					answer = inputOps.INPUT_BAD
					sleep(1)
					continue

			return __menuAnswer(C, answer)

		detachAll()
			__ready = FALSE
			for(var/menu/M in children)
				children -= M
				M.parent = null
			__ready = TRUE

		detatch(menu/M)
			__ready = FALSE
			if(M.parent == src && M in children)
				children -= M
				M.parent = null
			__ready = TRUE

		attach()
			__ready = FALSE
			for(var/menu/D in args)
				if(istype(D, /menu))
					children += D
					D.parent = src
			__ready = TRUE

/* Idea for a callback object. It *requires* an object-form of call,
 * since it can't verify via hascall() whether other procedures exist.
 */

textMatcher
	New(list/L)
		if(istype(L)) setKeywords(L)

	var
		list/__keywords=new()
		__ignoreCase = TRUE
		__partial = TRUE

	proc
		setIgnorecase(n)
			__ignoreCase = n

		setPartial(n)
			__partial = n

		setKeywords(list/L)
			if(istype(L, /list))
				__keywords = L
			else if(istext(L))
				for(var/a in args) __keywords += a

		match(text, ignoreCase = __ignoreCase, partial = __partial)
			for(var/a in __keywords)
				if(partial)
					if(inputOps.short2full(text,a,ignoreCase)) return a
				else
					if(ignoreCase)
						if(cmptext(text,a)) return a
					else
						if(cmptextEx(text,a)) return a
			return FALSE

callWrapper
	New(datum/__obj, __func)
		if(!__obj || !istype(__obj))
			valid = FALSE
		if(!__func || !istext(__func))
			valid = FALSE
		if(!hascall(__obj, __func))
			valid = FALSE

		if(istype(__obj)) src.__obj = __obj
		if(__func) src.__func = __func

	var
		valid = TRUE
		datum/__obj
		__func

	proc
		go()
			if(!valid) return
			return call(__obj, __func)(arglist(args))

