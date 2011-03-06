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
