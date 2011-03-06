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

menuAction
	parent_type = /callInterface
	export_all = FALSE

	proc
		findMenuAction(M)
			. = Run("findMenuAction", M)

		detach(menuAction/A)
			. = Run("detach", A)

		detachAll()
			. = Run("detachAll", args)

		attach()
			. = Run("attach", args)

		getDisplayText()
			. = Run("getDisplayText")

		setCallback(callObject/O)
			. = Run("setCallback", O)

		setParent(menuAction/A)
			. = Run("setParent", A)

		getParent()
			. = Run("getParent")

		match(text)
			. = Run("match", text)

		ask(client/C)
			. = Run("ask", C)
