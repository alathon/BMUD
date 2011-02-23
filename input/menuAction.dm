menuAction
	parent_type = /callInterface
	export_all = FALSE

	proc
		findMenu(M)
			. = Run("findMenu", M)

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
