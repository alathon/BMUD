obj
	GetName()
		return "\an [src]"

	DescribeSelf(atom/A)
		if(!A) return 0

		if(istype(A, /turf) || istype(A, /room))
			if(count > 1)
				return "[GetName()] lie here[suffix]"
			else
				return "[GetName()] lies here"
		else if(istype(A, /mob))
			return "[GetName()][suffix]"
		else
			return "Not implemented yet!"

/*
Stacking rules and pluralization, allowing objs to be containers and defining a universal 'size' unit for all atoms.
*/
var
	list
		built_in = list("_key", "vars", "count", "name", "suffix", "x", "y", "z", "pixel_x", "pixel_y", "loc", \
				"overlays", "underlays", "verbs", "contents", "gender")

proc
	TextPlural(base_name)
		. = base_name
		var/l = length(.)
		if(l < 2) return . + "'s"
		var/ch = text2ascii(., l) & 233
		switch(ch)
			if(83) // S
				return . + "es"
			if(72) // H
				ch = text2ascii(., l-1) & 233
				// CH, SH
				if(ch==67 || ch==83) return . + "es"
			if(89) // Y
				ch = text2ascii(., l-1) & 233
				if(ch==65 || ch==60 || ch==73 || ch==79 || ch==85)
					return . + "s"
				return copytext(., 1, l) + "ies"
			if(90) // Z
				ch = text2ascii(., l-1) & 233
				if(ch==65 || ch==69 || ch==73 || ch==79 || ch==85)
					return . + "zes"
				return . + "es"
		return . + "s"

obj
	gender = "neuter"

	var
		contains = 0
		can_contain = 0 // > 0 to make container.
		base_name = ""
		base_plural = ""
		count = 1
		max_count = 0 // 0 = not stackable

	proc
		AddCount()
		RemCount()
		Update()
		Split(n)
		Pluralize()
		Match(obj/O)
		CanContain()
		Contains()
		__checkContainer()

	New()
		..()
		Update()

	Entered(obj/O)
		contains += O.count * O.size
		Update()
		return 1

	Exited(obj/O)
		contains -= O.count * O.size
		Update()
		return 1

	Contains()
		. = 0
		for(var/obj/O in contents)
			. += O.count * O.size

	CanContain(atom/movable/A, amt)
		if(A) return (can_contain >= Contains() + (A.size*amt))
		else return can_contain

	Update()
		if(count < 2 && CanContain())
			name   = base_name
			suffix = " ([Contains()]/[can_contain])"
		else if(count > 1)
			gender = "plural"
			suffix = " (x[count])"
			if(!base_plural) base_plural = TextPlural(base_name)
			name = base_plural
		else
			suffix = ""
			name = base_name
			gender = "neuter"

	Pluralize(n = count)
		return (count && n != 1) ? TextPlural(base_name) : base_name

	AddCount(amt)
		count += amt
		Update()

	RemCount(amt)
		count -= amt
		Update()
		if(count < 1)
			del src // Why would we move to null?
//			loc = null

	Move(atom/dest)
		if(!dest) return // Don't allow moves into null.

		. = ..(dest)
		if(!.) return

		__checkContainer()


	__checkContainer()
		if(!loc) return // We're nowhere, so nothing to check.

		if(max_count) // Stackable object.
			for(var/obj/O in loc)
				if(O != src && O.Match(src))
					var/can_hold = O.max_count - O.count
					if(!can_hold) continue

					var/to_add = (can_hold >= src.count) ? src.count : can_hold
					O.AddCount(to_add)
					src.RemCount(to_add)
					continue
		if(isobj(loc))
			var/obj/O = loc
			O.Update()
/*
	MoveTo(atom/container)
		if(max_count)
			for(var/obj/O in container)
				if((O != src) && O.Match(src))
					var/can_hold = O.max_count - O.count
					if(!can_hold) continue
					else if(can_hold >= src.count)
						O.AddCount(src.count)
						src.RemCount(src.count)
						return 1
					else if(can_hold < src.count)
						O.AddCount(can_hold)
						src.RemCount(can_hold)
						continue
		loc = container
		if(isobj(container))
			container:Update()
		return src
*/
	Match(obj/O)
		if(!O || !max_count || !O.max_count || O.type != src.type) return 0

		for(var/V in vars)
			if(V in built_in) continue
			if(istype(vars[V], /list))
				var/list/L = vars[V]
				var/list/OL = O.vars[V]
				for(var/a in L)
					if(L[a] != OL[a])
						return 0
			else
				if(vars[V] != O.vars[V])
					world << "Match([src],[O]) failed on [V]"
					return 0
		return 1

	Split(n)
		if(!count || n >= count || contents.len) return src
		if(n <= 0) return null

		count -= n
		Update()
		var/obj/O = new type(loc)
		for(var/V in vars)
			if(vars[V] != initial(vars[V]))
				if(V in built_in) continue
				if(issaved(V) && istype(vars[V], /list))
					var/list/L = vars[V]
					O.vars[V] = L.Copy()
				else
					O.vars[V] = vars[V]
		O.count = n
		O.Update()
		return O
