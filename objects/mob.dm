mob
	var
		direction

	proc
		isIngame()
			return 1 // Everyone's ingame right now.

// Old, non-revamped code
mob/proc
	Drop(obj/Drop, amount)
		if(!isobj(Drop))
			if(istext(Drop) && cmptext(Drop, "all")) // drop all
				SendTxt("You drop everything you have!", src, DT_MISC, 0)
				for(var/obj/O in contents)
					Drop(O,O.getCount())
				return 1
			else
				SendTxt("Drop what??", src, DT_MISC, 0)
				return 0

		if(isnum(amount) && amount < 0) amount = 1

		if(amount == "all" || amount >= Drop.getCount())
			var/string = "You drop [Drop.getName()] on the ground."
			if(Drop.Move(loc))
				SendTxt(string, src, DT_MISC)
				return 1

			SendTxt("You cannot drop that here.", src, DT_MISC, 0)
			return 0

		else if(amount < Drop.getCount())
			var/obj/Split = Drop.split(amount)
			var/string = "You drop [Split.getName()] on the ground"
			if(Split.Move(loc))
				SendTxt(string, src)
				return 1

			SendTxt("You cannot drop that here.", src, DT_MISC, 0)
			del Split
			Drop.__addCount(amount)
			return 0
		else
			CRASH("INVALID CALL TO DROP: [amount]")

	Put(obj/Put,obj/Container,amount)
		if(!isobj(Container))
			if(isobj(Put) && amount == "all") // put all X
				SendTxt("You put everything you have into [Put.getName()]", src)
				for(var/obj/O in contents - Put)
					if(!O.canContain()) // Dont try and move containers.
						Put(O,Put,O.getCount())
				return 1
			else
				SendTxt("Put what where?", src, DT_MISC, 1)
				return 0

		if(istext(Put) && cmptext(Put, "all")) // Put all in something
			for(var/obj/O in contents - Container)
				Put(O,Container,O.getCount())
			return 1

		if(Put.canContain())
			SendTxt("You cannot put a container into something else!", src.client, DT_MISC, 0)
			return 0

		if(isnum(amount) && amount < 0) amount = 1
		if(amount == "all" || amount >= Put.getCount())
			var/string = "You put [Put.getName()] into [Container.getName()]"
			if(Container.canContain(Put, Put.getCount()))
				if(Put.Move(Container))
					SendTxt(string, src)
					return 1
			SendTxt("There is not enough room in [Container.getName()] for that.", src)
			return 0
		else if(amount < Put.getCount())
			if(Container.canContain(Put, amount))
				var/obj/Split = Put.split(amount)
				var/string = "You put [Split.getName()] into [Container.getName()]"
				if(Split.Move(Container))
					SendTxt(string, src)
					return 1
				else
					del Split
					Put.__addCount(amount)
			SendTxt("There is not enough room in [Container.getName()] for that.", src)
			return 0
		else
			CRASH("INVALID CALL TO PUT: [amount]")

	Pickup(obj/Get,obj/From,amount)
		if(!isobj(Get))
			if(istype(From, /atom) && istext(Get) && cmptext(Get, "all")) // Get all
				for(var/obj/O in From.contents)
					Pickup(O,From,O.getCount())
				return 1
			else
				return 0

		if(isnum(amount) && amount < 0) amount = 1
		if(!amount || amount == "all" || amount >= Get.getCount())
			if(isobj(From))
				SendTxt("You get [Get.getName()] from [From.getName()]", src)
			else
				SendTxt("You get [Get.getName()]", src)
			Get.Move(src)
			return 1
		else if(amount < Get.getCount()) // Not all
			var/obj/Split = Get.split(amount)
			var/split_name = Split.getName()
			if(!Split.Move(src))
				SendTxt("You were unable to get [split_name]", src)
				Get.__addCount(amount)
				del Split
				return 0
			if(isobj(From))
				SendTxt("You get [split_name] from [From.getName()]", src)
			else
				SendTxt("You get [split_name]", src)
			return 1
		else
			CRASH("INVALID CALL TO PICKUP: [amount] > [Get.getCount()]")

mob
	density = 0
	var
		password = "" // used in character templates

	proc
		CanSee(atom/A)
			return (see_invisible >= A.invisibility)

		Look(a, b)
			if(!client) return

			if(!a && !b)
				if(istype(loc, /room))
					var/room/R = loc
					SendTxt(R.describeSelf(src), src)
				else if(istype(loc, /turf))
					return Look(20,10)
				else
					SendTxt("Unidentified location. Please report.", src, 0)
					return
			else
				if(istype(a, /atom))
					SendTxt(a:describeSelf(src), src)
				
				/* Phased out: Support for maps
				else if(isnum(a) && isnum(b))
					SendTxt(FormatMap(a,b),src,0)
				*/


	describeSelf(atom/A)
		if(!A) return 0

		if(istype(A, /turf) || istype(A, /room))
			return getName()
		else if(istype(A, /mob))
			return src.GetDesc(A)
		else
			return "Not implemented yet."
