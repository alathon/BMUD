client
	var
		menu/current_menu = null

	proc
		Percieve()
		LookRoom()
		LookObj()
		LookMob()
		LookInvalid()

	Percieve(target)
		if(!target) // Percieve self
			src << "You percieve yourself... ! /TestMsg"
			return 0

		else
			if(istype(target, /mob))
				return LookMob(target)
			else if(istype(target, /obj))
				return LookObj(target)
			else
				return LookInvalid(target)

	LookMob(mob/M)
		SendTxt(M.DescribeSelf(src), src)
		return 1

	LookObj(obj/O)
		SendTxt(O.DescribeSelf(src), src)
		return 1

	LookInvalid(T)
		SendTxt("You look around you, but can't seem to find [T].", src, 0)
		return 1

	proc/SetMenu(menu/M)
		if(!M) return 0

		current_menu = M
		M.GetInput(src)


