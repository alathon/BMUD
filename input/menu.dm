// TODO: Consider revamping - Maybe ? A bit messy...

menu
	New(list/keywords, displayText, menu/__parent)
		if(keywords)
			if(istext(keywords)) keywords = list(keywords)
			src.__keywords = new(keywords)
			src.name = keywords[1]
		if(displayText)
			src.__displayText = displayText
		if(__parent)
			__parent.attach(src)
		__ready = TRUE

	var
		name = ""

		/* Private variables */
		__ready = FALSE
		__allowExit = TRUE
		__allowBack = TRUE
		__displayText
		form/__form
		callObject/__callback
		callObject/__inputFormatter
		textMatcher/__keywords
		menu/__parent
		list/__children = new()

	proc
		// Default procedure for menu display. Called by __getInput()
		// to figure out how the Input's question should look.
		defaultQuestionFormat()
			for(var/menuAction/M in __children)
				. += "[M.getDisplayText()]\n"
			. += "Select an item from the menu\n"


		// Sets a function to format the Input question in
		// __getInput(). If set, defaultQuestionFormat() won't be
		// used for this purpose.
		setInputFormatter(callObject/O)
			if(istype(O) || isnull(O)) __inputFormatter = O

		// Recursive function to find a specific menu
		// Expects a string, and returns a menu reference
		// or null if no menu is found.
		findMenuAction(n)
			if(src.name == n) return src
			for(var/menuAction/M in __children)
				. = M.findMenuAction(n)
				if(!isnull(.)) return .
			return null

		// Exposes the match() function of the private
		// __keywords object. Will check whether text
		// matches to any of the keywords associated with
		// this menu.
		match(text)
			return __keywords.match(text)

		// Getter for private __displayText
		getDisplayText()
			return __displayText

		// Sets the callback object, or removes it.
		// If a menu has a __callback and has no
		// __children, the __callback is executed. This
		// allows a menu to act as a procedure, to for
		// instance quit the game or something else.
		setCallback(callObject/C)
			if(istype(C) || isnull(C)) __callback = C

		// This is the main entry-point for the menu.
		// It will wait until the menu is in a ready state,
		// and then ask for input and match it up against
		// the __children of the menu. If the
		// input matches a menuAction child, it will return
		// child.ask(C), essentially moving the user to a different
		// menu. 
		ask(client/C)
			__getReady(C)
			if(!C) return
			if(istype(__callback) && !length(__children))
				var/c = __callback.Run(C, src)
				return c

			var/answer = inputOps.INPUT_BAD
			while(C && answer == inputOps.INPUT_BAD)
				var/Input/I = __getInput()
				answer = I.getInput(C)
				answer = __parse(answer)
				if(answer == inputOps.INPUT_NOT_READY)
					answer = inputOps.INPUT_BAD
					sleep(1)
					continue

			var/menuAction/A = menuOps.menuAnswer(src, answer)
			if(istype(A)) return A.ask(C)
			else return

		// Remove all children. This function is recursive by default.
		detachAll(recurse=1)
			__ready = FALSE
			for(var/menuAction/M in __children)
				__children -= M
				M.setParent(null)
				if(recurse) M.detachAll()
			__ready = TRUE

		// Remove the menuAction M if it is a child of this menu.
		detatch(menuAction/M)
			__ready = FALSE
			if(M.getParent() == src && M in __children)
				__children -= M
				M.setParent(null)
			__ready = TRUE

		// Adds the menuActions supplied to the children of this menu
		// Input can either be a list of menuAction objects, or
		// menuAction objects as individual parameters (but not both).
		// Thus, both of these calling conventions are legal:
		// attach(list(menuAction1,menuAction2,menuAction3))
		// attach(menuAction1, menuAction2, menuAction3)
		attach(list/L)
			__ready = FALSE
			if(!istype(L)) L = args
			for(var/menuAction/D in L)
				if(istype(D))
					__children += D
					D.setParent(src)
			__ready = TRUE

		/* PRIVATE FUNCTIONS */
		// For default callback mechanisms to navigate to menu's
		__callbackRootMenu()
			var/menuAction/M = __parent
			while(1)
				if(M.getParent()) M = M.getParent()
				else break
			return M

		__callbackBack()
			return menuOps.MENU_BACK

		__callbackRepeat()
			return menuOps.MENU_REPEAT

		__callbackExit()
			return menuOps.MENU_EXIT


		// Parses an answer. Should either return a menu command,
		// i.e. menuOps.MENU_BACK, a menu reference, or return bad
		// input with inputOps.INPUT_BAD
		__parse(answer)
			if(inputOps.isEmpty(answer))
				return 

			if(answer == inputOps.INPUT_NOT_READY)
				return answer

			for(var/menuAction/M in __children)
				if(M.match(answer))
					return M


			if(__allowExit && inputOps.short2full(answer,"exit",1))
				return menuOps.MENU_EXIT
			if(__allowBack && inputOps.short2full(answer,"back",1))
				return menuOps.MENU_BACK

			return inputOps.INPUT_BAD

		__getReady(client/C)
			while(C && !__ready) sleep(1)

		__getInput()
			var/inputQuestion = __inputQuestion()
			var/Input/I = new(inputQuestion)
			I.setAllowempty(TRUE)
			return I

		__inputQuestion()
			if(istype(__inputFormatter))
				return __inputFormatter.Run(src)
			else
				return defaultQuestionFormat()

