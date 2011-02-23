form/menu
	New(list/keys, dtext)
		setKeywords(keys)
		setDisplayText(dtext)
		..()

	var
		textMatcher/__keywords
		menuAction/__parent
		callObject/__callback
		__displayText

	proc
		__exitCode(client/C, form/F, exit)
			if(!C) return
			if(exit == formOps.EXIT_DISCONNECT)
				exit = menuOps.MENU_EXIT
			else if(exit == formOps.EXIT_EXIT)
				exit = menuOps.MENU_REPEAT
			else if(exit == formOps.EXIT_COMPLETE)
				if(istype(__callback))
					exit = __callback.Run(C, F)
					del F
				else
					exit = menuOps.MENU_EXIT

			var/menuAction/action = menuOps.menuAnswer(src, exit)
			if(istype(action, /menuAction))
				return action.ask(C)
			else
				return

		setKeywords(list/L)
			if(!L) return
			if(istext(L)) L = list(L)
			if(length(L))
				if(__keywords) del __keywords
				__keywords = new(L)

		setCallback(callObject/O)
			if(istype(O) && O.valid) __callback = O

		getDisplayText()
			return __displayText

		setDisplayText(t)
			__displayText = t

		getParent()
			return __parent

		setParent(menuAction/A)
			src.__parent = A

		match(text)
			return __keywords.match(text)

		ask(client/C)
			var/form/F = src.copy()
			var/exit = F.begin(C)
			return __exitCode(C, F, exit)