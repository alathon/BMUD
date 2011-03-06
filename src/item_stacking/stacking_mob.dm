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


// TODO containers / put / get from containers are totally untested
mob/proc
	get(obj/item, obj/from, amount)
		if(!item && amount == "all")
			return __getAll(from)

		else if(istype(item))
			if(amount == "all")
				return __getItem(item, from)
			else if(isnum(amount))
				if(amount >= item.getCount())
					return __getItem(item, from)
				var/obj/Split = item.split(amount)
				. = __getItem(Split, from)
				if(!.)
					del Split
					item.__addCount(amount)

	drop(obj/item, amount)
		if(!item && amount == "all")
			return __dropAll()

		else if(istype(item))
			if(amount == "all")
				return __dropItem(item)
			else if(isnum(amount))
				if(amount >= item.getCount())
					return __dropItem(item)
				var/obj/Split = item.split(amount)
				. = __dropItem(Split)
				if(!.)
					del Split
					item.__addCount(amount)

	put(obj/item, obj/container, amount)
		if(!item && amount == "all")
			return __putAll(container)

		else if(istype(item))

			if(amount == "all")
				return __putItem(item, container)
			else if(isnum(amount))
				if(amount >= item.getCount())
					return __putItem(item, container)
				var/obj/Split = item.split(amount)
				. = __putItem(Split, container)
				if(!.)
					del Split
					item.__addCount(amount)
	__dropAll()
		for(var/obj/O in contents)
			__dropItem(O)

	__dropItem(obj/item)
		if(!isobj(item))
			. = "\ref[src] attempted to drop non-item \[[item]\]"
			Log(., EVENT_BADSTUFF)
			CRASH(.)

		if(!(item in src))
			. = "\ref[src] attempted to drop \[[item]\] not from inventory"
			Log(., EVENT_BADSTUFF)
			CRASH(.)

		var/msg = "You drop [item.getName()] on the ground."
		if(item.Move(loc))
			sendTxt(msg, src)
			return 1

		sendTxt("You cannot drop that here.", src, DT_MISC, 0)
		return 0


	__putAll(obj/container)
		if(!isobj(container))
			Log("Attempt to put inventory into non-object.", EVENT_BADSTUFF)
			return 0

		for(var/obj/O in contents)
			if(O == container) continue
			__putItem(O, container)

	__putItem(obj/put, obj/container)
		if(!isobj(put))
			. = "Attempt to put non-object"
			Log(. , EVENT_BADSTUFF)
			CRASH(.)

		if(!isobj(container))
			. = "Attempt to put [put.getName()](\ref[put]) into non-object."
			Log(. , EVENT_BADSTUFF)
			CRASH(.)

		if(!(put in src))
			. = "\ref[src] attempted to put \[[put]\] not from inventory"
			Log(., EVENT_BADSTUFF)
			CRASH(.)

		if(!(container in src) && !(container in loc))
			. = "\ref[src] attempted to put into \[[container.getName()]\] not on ground/in inventory"
			Log(., EVENT_BADSTUFF)
			CRASH(.)

		if(put == container)
			sendTxt("You can't put something inside itself!", src)
			return 0

		if(put.canContain())
			sendTxt("You cannot put a container inside another container.", src, DT_MISC, 0)
			return 0

		if(container.canContain(put))
			var/msg = "You put [put.getName()] into [container.getName()]."
			if(put.Move(container))
				sendTxt(msg, src)
				return 1

			sendTxt("You were unable to put [put.getName()] into [container.getName()].", 
					src)
			return 0
		else
			sendTxt("There isn't enough room in [container.getName()] for [put.getName()]",
					src)
			return 0



	__getItem(obj/item, obj/from)
		if(!isobj(item))
			. = "Attempt to get non-object"
			Log(., EVENT_BADSTUFF)
			CRASH(.)

		if(from && !isobj(from))
			. = "Attempt to get from a non-object"
			Log(., EVENT_BADSTUFF)
			CRASH(.)

		var/msg = "get [item.getName()]"
		if(!from)
			msg += "."
		else
			msg += " from [from.getName()]."
			if(!(item in from))
				. = "Attempt to get [item.getName()] which isn't in [from.getName()]"
				Log(., EVENT_BADSTUFF)
				CRASH(.)

			if(!from.canTake(item, src))
				return 0

		if(item.Move(src))
			sendTxt("You [msg]", src)
			return 1
		else
			sendTxt("You cannot [msg]", src)
			return 0

	__getAll(obj/c)
		var/obj/container
		if(istype(c))
			if(c in loc || c in src) container = c

		if(loc && istype(loc, /room))
			if(isobj(container))
				sendTxt("You begin picking up everything from [container.getName()]",src)
				for(var/obj/O in container)
					__getItem(O, container)
			else
				sendTxt("You pick up everything you can find!", src, DT_MISC, 0)
				for(var/obj/O in loc)
					__getItem(O)
