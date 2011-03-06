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

menuOptions
	proc
		menuAnswer(a, i)
			// Note: If this if statement is moved below
			// the below stuff assigning a value to A, then
			// BYOND does a silent procedure crash.
			if(istype(i, /menuAction))
				return i

			var/menuAction/A
			if(!istype(a, /menuAction))
				A = new/menuAction(a)
			else
				A = a

			if(i == menuOps.MENU_REPEAT)
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
				return M.findMenuAction(sub)

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
