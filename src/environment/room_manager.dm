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


var/service/roomMan/room_manager
service/roomMan
	name = "RoomManager"

	var
		list
			clusters[0]

	proc
		AddCluster()
		RemCluster()
		GetCluster()
		GetRoom()
		GetObj()
		GetMob()
		GetClusterByName()
		LoadCluster()
		UnloadCluster()
		CreateCluster()

	bootHook()
		if(!room_manager) room_manager = src
		return 1

	initHook()
		mud.logMsg("Loading demo area")
		var/roomCluster/C = CreateCluster("Test Cluster", "This is the test cluster")
		AddCluster(C)
		var/room/one = C.CreateRoom("Test One", "Test One Description")
		var/room/two = C.CreateRoom("Test Two", "Test Two Description")
		C.AddRoom(one)
		C.AddRoom(two)
		one.north = two
		two.south = one
		var/obj/O = new()
		O.__maxCount = 5
		O.__count = 5
		O.__base_name = "rose"
		O.update()
		O.Move(one)
		return 1

	haltHook()
		if(room_manager == src) room_manager = null
		return 1

	GetRoom(...)
		if(length(args) < 2) return 0
		var/roomCluster/C = (isnum(args[1])) ? GetCluster(args[1]) : GetClusterByName(args[1])
		if(!C) return 0
		return C.GetRoom(args[2])

	GetObj(...)
		if(length(args) < 2) return 0
		var/roomCluster/C = GetCluster(args[1])
		if(!C) return 0
		return C.GetObj(args[2])

	GetMob(...)
		if(length(args) < 2) return 0
		var/roomCluster/C = GetCluster(args[1])
		if(!C) return 0
		return C.GetMob(args[2])

	CreateCluster(n, d)
		var/roomCluster/C = new()
		C.name = n
		C.desc = d
		if(!AddCluster(C)) del C
		return (C || null)

	GetClusterByName(_name)
		for(var/roomCluster/C in clusters)
			if(cmptext(C.name, _name)) return C
		return null

	GetCluster(uid)
		if(!isnum(uid) || uid < 1 || uid > length(clusters)) return 0
		return clusters[uid]

	AddCluster(roomCluster/c)
		if(!c || !istype(c, /roomCluster)) return 0
		if(!clusters) clusters = new()
		if(c in clusters) return 0

		var/new_len = ++clusters.len
		clusters[new_len] = c
		c.tag = new_len
		return c

	RemCluster(roomCluster/C)
		if(isnum(C)) C = GetCluster(C)
		if(!istype(C,/roomCluster)) return 0

		C.RemoveSelf()
		if(C.tag == length(clusters))
			clusters.len--
		else
			clusters.Cut(C.tag, C.tag+1)
		return clusters.len
