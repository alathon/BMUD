var/inputOptions/inputOps = new()

inputOptions
	New()
		..()
		addParser("any", /inputParser/answer_any)
		addParser("list", /inputParser/answer_list)
		addParser("num", /inputParser/answer_num)
		addParser("yesno", /inputParser/answer_yesno)
		addFormatter("default", /inputFormatter/default)

	proc
		addParser(key, path)
			if(key in __inputParsers) return 0
			__inputParsers[key] = new path()
			return __inputParsers[key]

		addFormatter(key, path)
			if(key in __inputFormatters) return 0
			__inputFormatters[key] = new path()
			return __inputFormatters[key]

		getParser(n)
			if(n in __inputParsers) return __inputParsers[n]
			else if(ispath(n))
				return new n()

		getFormatter(n)
			if(n in __inputFormatters) return __inputFormatters[n]
			else if(ispath(n))
				return new n()

	var
		list/__inputParsers = new()
		list/__inputFormatters = new()
		STATE_INIT  = 1
		STATE_READY = 2
		STATE_ACCEPT = 3
		STATE_DONE = 4
		STATE_ERROR = 5

		FORMAT_QUESTION = 1
		FORMAT_ERROR = 2