mob/proc
	Drop(obj/Drop, amount)
		if(!isobj(Drop))
			if(istext(Drop) && cmptext(Drop, "all")) // drop all
				SendTxt("You drop everything you have!", src, DT_MISC, 0)
				for(var/obj/O in contents)
					Drop(O,O.count)
				return 1
			else
				SendTxt("Drop what??", src, DT_MISC, 0)
				return 0

		if(isnum(amount) && amount < 0) amount = 1

		if(amount == "all" || amount >= Drop.count)
			var/string = "You drop [Drop.GetName()] on the ground."
			if(Drop.Move(loc))
				SendTxt(string, src, DT_MISC)
				return 1

			SendTxt("You cannot drop that here.", src, DT_MISC, 0)
			return 0

		else if(amount < Drop.count)
			var/obj/Split = Drop.Split(amount)
			var/string = "You drop [Split.GetName()] on the ground"
			if(Split.Move(loc))
				SendTxt(string, src)
				return 1

			SendTxt("You cannot drop that here.", src, DT_MISC, 0)
			del Split
			Drop.AddCount(amount)
			return 0
		else
			CRASH("INVALID CALL TO DROP: [amount]")

	Put(obj/Put,obj/Container,amount)
		if(!isobj(Container))
			if(isobj(Put) && amount == "all") // put all X
				SendTxt("You put everything you have into [Put.GetName()]", src)
				for(var/obj/O in contents - Put)
					if(!O.CanContain()) // Dont try and move containers.
						Put(O,Put,O.count)
				return 1
			else
				SendTxt("Put what where?", src, DT_MISC, 1)
				return 0

		if(istext(Put) && cmptext(Put, "all")) // Put all in something
			for(var/obj/O in contents - Container)
				Put(O,Container,O.count)
			return 1

		if(Put.CanContain())
			SendTxt("You cannot put a container into something else!", src.client, DT_MISC, 0)
			return 0

		if(isnum(amount) && amount < 0) amount = 1
		if(amount == "all" || amount >= Put.count)
			var/string = "You put [Put.GetName()] into [Container.GetName()]"
			if(Container.CanContain(Put, Put.count))
				if(Put.Move(Container))
					SendTxt(string, src)
					return 1
			SendTxt("There is not enough room in [Container.GetName()] for that.", src)
			return 0
		else if(amount < Put.count)
			if(Container.CanContain(Put, amount))
				var/obj/Split = Put.Split(amount)
				var/string = "You put [Split.GetName()] into [Container.GetName()]"
				if(Split.Move(Container))
					SendTxt(string, src)
					return 1
				else
					del Split
					Put.AddCount(amount)
			SendTxt("There is not enough room in [Container.GetName()] for that.", src)
			return 0
		else
			CRASH("INVALID CALL TO PUT: [amount]")

	Pickup(obj/Get,obj/From,amount)
		if(!isobj(Get))
			if(istype(From, /atom) && istext(Get) && cmptext(Get, "all")) // Get all
				for(var/obj/O in From.contents)
					Pickup(O,From,O.count)
				return 1
			else
				return 0

		if(isnum(amount) && amount < 0) amount = 1
		if(!amount || amount == "all" || amount >= Get.count)
			if(isobj(From))
				SendTxt("You get [Get.GetName()] from [From.GetName()]", src)
			else
				SendTxt("You get [Get.GetName()]", src)
			Get.Move(src)
			return 1
		else if(amount < Get.count) // Not all
			var/obj/Split = Get.Split(amount)
			if(!Split.Move(src))
				SendTxt("You were unable to get [Split.GetName()]", src)
				Get.AddCount(amount)
				del Split
				return 0
			if(isobj(From))
				SendTxt("You get [Split.GetName()] from [From.GetName()]", src)
			else
				SendTxt("You get [Split.GetName()]", src)
			return 1
		else
			CRASH("INVALID CALL TO PICKUP: [amount] > [Get.count]")

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
					SendTxt(R.DescribeSelf(src), src)
				else if(istype(loc, /turf))
					return Look(20,10)
				else
					SendTxt("Unidentified location. Please report.", src, 0)
					return
			else
				if(istype(a, /atom))
					SendTxt(a:DescribeSelf(src), src)
				
				/* Phased out: Support for maps
				else if(isnum(a) && isnum(b))
					SendTxt(FormatMap(a,b),src,0)
				*/


	DescribeSelf(atom/A)
		if(!A) return 0

		if(istype(A, /turf) || istype(A, /room))
			return GetName()
		else if(istype(A, /mob))
			return src.GetDesc(A)
		else
			return "Not implemented yet."

	Stat() // DS compliance
		if(!istype(src, /mob/login))
			if(statpanel("Character"))
				stat("Name: ", "[name]")
				stat("Gender: ", "[gender]")
				if(length(contents))
					stat("Inventory", "")
					stat(contents)


