/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\environment\room_manager.dm

The room manager keeps track of room clusters, also supplying a general set of procedures
to fetch rooms, objs and mobs within a cluster without maintaining a direct reference to the
cluster itself.
*/

var/_service/room_manager/room_manager
_service/room_manager
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

	Loaded()
		if(!room_manager) room_manager = src
		var/room_cluster/C = CreateCluster("Test Cluster", "This is the test cluster")
		AddCluster(C)
		var/room/one = C.CreateRoom("Test One", "Test One Description")
		var/room/two = C.CreateRoom("Test Two", "Test Two Description")
		C.AddRoom(one)
		C.AddRoom(two)
		one.AddExit("north", two)
		two.AddExit("south", one)
		var/obj/O = new()
		O.__maxCount = 5
		O.__count = 5
		O.__base_name = "rose"
		O.keywords = list("rose")
		O.update()
		O.Move(one)
		..()

	Unloaded()
		if(room_manager == src) room_manager = null
		..()

	GetRoom(...)
		if(length(args) < 2) return 0
		var/room_cluster/C = (isnum(args[1])) ? GetCluster(args[1]) : GetClusterByName(args[1])
		if(!C) return 0
		return C.GetRoom(args[2])

	GetObj(...)
		if(length(args) < 2) return 0
		var/room_cluster/C = GetCluster(args[1])
		if(!C) return 0
		return C.GetObj(args[2])

	GetMob(...)
		if(length(args) < 2) return 0
		var/room_cluster/C = GetCluster(args[1])
		if(!C) return 0
		return C.GetMob(args[2])

	CreateCluster(n, d)
		var/room_cluster/C = new()
		C.name = n
		C.desc = d
		if(!AddCluster(C)) del C
		return (C || null)

	GetClusterByName(_name)
		for(var/room_cluster/C in clusters)
			if(cmptext(C.name, _name)) return C
		return null

	GetCluster(uid)
		if(!isnum(uid) || uid < 1 || uid > length(clusters)) return 0
		return clusters[uid]

	AddCluster(room_cluster/c)
		if(!c || !istype(c, /room_cluster)) return 0
		if(!clusters) clusters = new()
		if(c in clusters) return 0

		var/new_len = ++clusters.len
		clusters[new_len] = c
		c._uid = new_len
		return c

	RemCluster(room_cluster/C)
		if(isnum(C)) C = GetCluster(C)
		if(!istype(C,/room_cluster)) return 0

		C.RemoveSelf()
		if(C._uid == length(clusters))
			clusters.len--
		else
			clusters.Cut(C._uid, C._uid+1)
		return clusters.len
