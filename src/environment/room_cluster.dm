/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\environment\room_cluster.dm

A room cluster is a collection (or cluster) of rooms, grouped under a common name and description.
This is what most MUDs would refer to as a 'zone', or an 'area'.
*/
roomCluster
	var
		list
			rooms
			mobs
			objs

		name = "Undefined Name"
		desc = "Undefined Desc"

	proc
		RemoveSelf()
		CreateRoom()
		AddRoom()
		RemRoom()
		SetName()
		GetRoom()
		GetObj()
		GetMob()

	GetRoom(uid)
		if(!isnum(uid) || uid < 1 || uid > length(rooms)) return 0
		return rooms[uid]

	GetMob(uid)
		if(!isnum(uid) || uid < 1 || uid > length(mobs)) return 0
		return mobs[uid]

	GetObj(uid)
		if(!isnum(uid) || uid < 1 || uid > length(objs)) return 0
		return objs[uid]

	CreateRoom(_name, _desc)
		var/room/R = new()
		R.name = _name
		R.desc = _desc
		return R

	SetName(n)
		name = n

	AddRoom(room/R)
		if(!R || !istype(R, /room)) return 0

		if(!rooms) rooms = new()
		rooms.len++
		rooms[rooms.len] = R
		R.tag = rooms.len
		return R

	RemRoom(uid)
		var/len = length(rooms)
		if(!rooms || uid > len || uid < 1) return 0

		var/room/R = rooms[uid]
		del R // TODO: Clean up R properly, move players out, etc.
		if(uid == len)
			rooms.len--
		else
			rooms.Cut(uid, uid+1)
