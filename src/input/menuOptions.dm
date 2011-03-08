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
		menuAnswer(menu/a, i)
			if(!istype(a))
				Log("Invalid menu passed to menuOps.menuAnswer: [a]", EVENT_GENERAL)
				CRASH("Invalid menu passed to menuOps.menuAnswer: [a]")

			if(i == menuOps.MENU_REPEAT)
				return a
			else if(i == menuOps.MENU_BACK)
				return a.getParent()
			else if(i == menuOps.MENU_EXIT)
				return
			else if(i == inputOps.INPUT_BAD)
				return a
			else if(istype(i, /menu))
				return i
			else
				Log("Invalid menu answer [i]", EVENT_GENERAL)
				CRASH("Invalid menu answer [i]")

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
