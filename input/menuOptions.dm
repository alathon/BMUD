menuOptions
	proc
		menuAnswer(menuAction/A, i)
			if(istype(i, /menuAction))
				var/menuAction/M = i
				return M
			else if(i == menuOps.MENU_REPEAT)
				return A
			else if(i == menuOps.MENU_BACK)
				return A.getParent()
			else if(i == menuOps.MENU_EXIT)
				return
			else if(i == inputOps.INPUT_BAD)
				return A
			else
				Log("Invalid menu answer [i]", EVENT_GENERAL)
				CRASH("Invalid menu answer [i]")

		getMenu(key)
			if(key in predefined) return predefined[key]

		getSubmenu(main, sub)
			if(main in predefined)
				var/menuAction/M = predefined[main]
				return M.findMenu(sub)

		addMenu(menuAction/M, key)
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
