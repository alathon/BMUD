/*
Stacking rules and pluralization, allowing objs to be containers and defining a universal 'size' unit for all atoms.
*/
// TODO: This list shouldn't be global. Namespace pollution.


var
	list
		built_in = list("_key", "vars", "__count", "name", "suffix", "x", "y", "z", "pixel_x", "pixel_y", "loc", \
				"overlays", "underlays", "verbs", "contents", "gender")

proc
	textPlural(__base_name)
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

// Mobs/objs have a size, since objs can contain mobs and vice versa.
atom/movable/var/size=1

obj
	gender="neuter"

	var
		__contains=0
		__canContain=0
		__base_name = ""
		__base_plural = ""
		__count=1
		__maxCount=0

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

	Move(atom/dest)
		if(!dest) return // Don't allow moves into null.

		. = ..(dest)
		if(!.) return

		__checkContainer()

	proc/getContainTotal()
		. = 0
		for(var/obj/O in contents)
			. += O.__count * O.size

	proc/getBaseName()
		return __base_name

	proc/getPlural()
		return __base_plural

	proc/getCount()
		return __count

	// Can M take O from me?
	proc/canTake(obj/O, mob/M)
		if(!(O in src)) return 0
		return 1

	proc/canContain(atom/movable/A, amt)
		if(!amt && isobj(A))
			var/obj/O = A
			amt = O.getCount()

		if(A) return (__canContain >= getContainTotal() + (A.size*amt))
		else return __canContain

	proc/update()
		if(!__count) del src

		if(__count < 2 && canContain())
			setName(__base_name)
			suffix = " ([getContainTotal()]/[__canContain])"
		else if(__count > 1)
			gender = "plural"
			suffix = " (x[__count])"
			if(!__base_plural) __base_plural = textPlural(__base_name)
			setName(__base_plural)
		else
			suffix = ""
			setName(__base_name)
			gender = "neuter"


	proc/pluralize(n = __count)
		return (__count && n != 1) ? textPlural(__base_name) : __base_name


	proc/match(obj/O)
		if(!O || !__maxCount || !O.__maxCount || O.type != src.type) return 0

		for(var/V in vars)
			if(V in built_in) continue
			if(istype(vars[V], /list))
				var/list/L = vars[V]
				var/list/OL = O.vars[V]
				for(var/a in L)
					if(L[a] != OL[a])
						return 0
			else if(!issaved(vars[V]))
				continue
			else
				if(vars[V] != O.vars[V])
					return 0
		return 1

	proc/split(n)
		if(!__count || n >= __count || contents.len) return src
		if(n <= 0) return null

		__remCount(n)
		var/obj/O = new type(loc)
		for(var/V in vars)
			if(vars[V] != initial(vars[V]))
				if(V in built_in) continue
				if(!issaved(vars[V])) continue
				if(istype(vars[V], /list))
					var/list/L = vars[V]
					O.vars[V] = L.Copy()
				else
					O.vars[V] = vars[V]
		O.__setCount(n)
		return O

	proc/__setCount(amt)
		__count = amt
		update()

	proc/__addCount(amt)
		__count += amt
		update()

	proc/__remCount(amt)
		__count -= amt
		update()


	proc/__checkContainer()
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
