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


Command/MUD/obj_manip
	category = "\[0;36mObject Manipulation\[0m"

	drop
		format = "'drop'; num|!'all'; ?'of'; ?!obj(contents, user)"
		Process(mob/user, amount, obj/Drop)
			..()
			user.drop(Drop, amount)

		drop_2
			category = ""
			format = "'drop'; obj(contents, user)"
			Process(mob/user, obj/Drop)
				..(user, 1, Drop)

	// Put ?X|all OBJ(contents) ?in|into OBJ(contents | ground)
	put_contents
		priority = 2
		format = "'put'; num|!'all'; obj(contents, user); ?'in'|'into'; obj(contents, user)"
		Process(mob/user, amount, obj/Put, obj/Container)
			..()
			user.put(Put,Container,amount)

		put_contents_2
			category = ""
			format = "'put'; obj(contents, user); ?'in'|?'into'; obj(contents, user)"
			Process(mob/user, obj/Put, obj/Container)
				..(user, 1, Put, Container)

		put_contents_3
			category = ""
			format = "'put'; 'all'|'everything'; ?'in'|?'into'; obj(contents, user)"
			Process(mob/user, obj/Container)
				..(user, null, "all", Container)

	put_ground
		category = ""
		priority = 1
		format = "'put'; num|!'all'; obj(contents, user); ?'in'|'into'; obj(ground, user)"
		Process(mob/user, amount, obj/Put, obj/Container)
			..()
			user.put(Put,Container,amount)

		put_ground_2
			format = "'put'; obj(contents, user); ?'in'|?'into'; obj(ground, user)"
			Process(mob/user, obj/Put, obj/Container)
				..(user, 1, Put, Container)

		put_ground_3
			format = "'put'; 'all'|'everything'; ?'in'|?'into'; obj(ground, user)"
			Process(mob/user, obj/Container)
				..(user, null, "all", Container)

	// get ?all|number OBJ ?from ?OBJ
	// get OBJ
	// get OBJ ?from OBJ
	// get all|number OBJ
	// get all|number OBJ ?from OBJ

	get
		format = "'get'|'grab'; num|!'all'; ?!obj(ground, user)"
		Process(mob/user, amt, obj/O)
			..()
			user.get(O, null, amt)

		get_2
			format = "'get'|'grab'; obj(ground, user)"
			category = ""
			Process(mob/user, obj/O)
				..()
				user.get(O, null, "all")

		get_3
			format = "'get'|'grab'; obj(groundmob, user); ?'from'; obj(groundmob, user)"
			category = ""
			Process(mob/user, obj/obj_get, obj/obj_from)
				..()
				user.get(obj_get, obj_from, "all")

		get_4
			format = "'get'|'grab'; num|!'all'; obj(groundmob, user); ?'from'; obj(groundmob, user)"
			category = ""
			Process(mob/user, amt, obj/obj_get, obj/obj_from)
				..()
				user.get(obj_get, obj_from, amt)
/*
	get
		format = "~'get'|~'grab'|~'fetch'; num|!'all'; anything; ?'from'; ?!anything"
		Process(mob/user, amount, obj_get, obj_from)
			..()
			if(!obj_from) // get obj
				if(cmptext(amount, "all")) // get all?
					if(obj_get)
						var/obj/F = matchAtom(obj_get, user.contents + user.loc.contents, /obj)
						if(F)
							return user.Pickup("all", F, null)
						else
							sendTxt("Get all from what?", user, DT_MISC, 0)
							return 0
					else
						sendTxt("You frantically attempt to pick up everything on the ground!", user, DT_MISC, 0)
						return user.Pickup("all", user.loc, null)

				var/obj/O = matchAtom(obj_get, user.loc, /obj)
				if(O) // Object found on ground.
					user.Pickup(O,null,amount)
				else
					sendTxt("Couldn't find [obj_get]. Sorry!", user, DT_MISC, 0)

			else
				var/obj/From = matchAtom(obj_from, user.contents + user.loc.contents, /obj)
				if(!From)
					sendTxt("Unable to find container: [obj_from]. Sorry!", user, DT_MISC, 0)
					return 0

				if(cmptext(obj_get, "all"))
					return user.Pickup("all", From, null)

				else if(cmptext(amount, "all") && cmptext(obj_get, "from")) // get all from X?
					return user.Pickup("all", From, null)

				var/obj/Get = matchAtom(obj_get, From, /obj)
				if(!Get)
					sendTxt("Couldn't find [obj_get] in [From.getName()]. Sorry!", user, DT_MISC, 0)
					return 0

				user.Pickup(Get,From,amount)

		get_2
			category = ""
			format = "~'get'|~'grab'|~'fetch'; ?!anything; ?'from'; ?!anything"
			Process(mob/user, obj_get, obj_from)
				if(!obj_get)
					sendTxt("Get what?", user, DT_MISC, 0)
					return 0
				if(cmptext(obj_get, "all"))
					..(user, "all", obj_from, null)
				else
					..(user, 1, obj_get, obj_from)

		get_3
			category = ""
			format = "~'get'|~'grab'|~'fetch'; 'all'|'everything'; anything"
			Process(mob/user, obj_from)
				..(user, 0, "all", obj_from)
*/
	inventory
		format = "~'inventory'|'i'"
		Process(mob/user)
			..()
			. = "You are carrying the following items:\n"
			for(var/obj/O in user)
				. += "[O.describeTo(user)]\n"
			sendTxt(., user, DT_MISC)

Command/MUD/error
	priority = 0
	category = ""

	drop_error_1
		format = "'drop'; ?num|'all'"
		Process(mob/user)
			sendTxt("Drop what?", user, DT_MISC, 0)
			return 0

	put_error_1
		format = "'put'; obj(contents, user); ?'in'|?'into'"
		Process(mob/user, obj/put)
			if(istext(put))
				sendTxt("Put what?", user, DT_MISC, 0)
				return 0
			else
				sendTxt("Put [put.getName()] into what?", user, DT_MISC, 0)
				return 0

	put_error_2
		format = "'put'; num|!'all'; obj(contents, user); ?'in'|?'into'"
		Process(mob/user, amt, obj/put)
			if(istext(put))
				sendTxt("Put what?", user, DT_MISC, 0)
				return 0
			else
				sendTxt("Put [amt] [put.getName()] into what?", user, DT_MISC, 0)
				return 0


