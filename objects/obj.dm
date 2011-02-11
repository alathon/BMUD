obj
	GetName()
		return "\an [src]"

	DescribeSelf(atom/A)
		if(!A) return 0

		if(istype(A, /turf) || istype(A, /room))
			if(__count > 1)
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
		built_in = list("_key", "vars", "__count", "name", "suffix", "x", "y", "z", "pixel_x", "pixel_y", "loc", \
				"overlays", "underlays", "verbs", "contents", "gender")

proc
	TextPlural(__base_name)
		. = __base_name
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
		__contains = 0
		__canContain = 0 // > 0 to make container.
		__base_name = ""
		__base_plural = ""
		__count = 1
		__maxCount = 0 // 0 = not stackable

	proc
		__setCount()
		__addCount()
		__remCount()
		update()
		split(n)
		pluralize()
		match(obj/O)
		canContain()
		getPlural()
		getCount()
		getContainTotal()
		__checkContainer()

	New()
		..()
		update()

	Entered(obj/O)
		__contains += O.__count * O.size
		update()
		return 1

	Exited(obj/O)
		__contains -= O.__count * O.size
		update()
		return 1

	getContainTotal()
		. = 0
		for(var/obj/O in contents)
			. += O.__count * O.size

	getPlural()
		return __base_plural

	getCount()
		return __count

	canContain(atom/movable/A, amt)
		if(A) return (__canContain >= getContainTotal() + (A.size*amt))
		else return __canContain

	update()
		if(!__count) del src

		if(__count < 2 && canContain())
			name   = __base_name
			suffix = " ([getContainTotal()]/[__canContain])"
		else if(__count > 1)
			gender = "plural"
			suffix = " (x[__count])"
			if(!__base_plural) __base_plural = TextPlural(__base_name)
			name = __base_plural
		else
			suffix = ""
			name = __base_name
			gender = "neuter"

	pluralize(n = __count)
		return (__count && n != 1) ? TextPlural(__base_name) : __base_name

	__setCount(amt)
		__count = amt
		update()

	__addCount(amt)
		__count += amt
		update()

	__remCount(amt)
		__count -= amt
		update()

	Move(atom/dest)
		if(!dest) return // Don't allow moves into null.

		. = ..(dest)
		if(!.) return

		__checkContainer()


	__checkContainer()
		if(!loc) return // We're nowhere, so nothing to check.

		if(__maxCount) // Stackable object.
			for(var/obj/O in loc)
				if(O != src && O.match(src))
					var/can_hold = O.__maxCount - O.__count
					if(!can_hold) continue

					var/to_add = (can_hold >= src.__count) ? src.__count : can_hold
					O.__addCount(to_add)
					src.__remCount(to_add)
					continue
		if(isobj(loc))
			var/obj/O = loc
			O.update()

	match(obj/O)
		if(!O || !__maxCount || !O.__maxCount || O.type != src.type) return 0

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
					world << "match([src],[O]) failed on [V]"
					return 0
		return 1

	split(n)
		if(!__count || n >= __count || contents.len) return src
		if(n <= 0) return null

		__remCount(n)
		var/obj/O = new type(loc)
		for(var/V in vars)
			if(vars[V] != initial(vars[V]))
				if(V in built_in) continue
				if(issaved(V) && istype(vars[V], /list))
					var/list/L = vars[V]
					O.vars[V] = L.Copy()
				else
					O.vars[V] = vars[V]
		O.__setCount(n)
		return O
