/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\environment\map.dm

Map-related procedures, for drawing and interpreting surroundings.
*/
atom/var/_text = ""

proc
	DrawMap(size_x, size_y, atom/ref, use_view = 1)
		var/tmp
			list/display[size_y][size_x]
			focus_x = ref.x - (size_x/2)
			focus_y = ref.y + (size_y/2) - 1
			list/turfs = (use_view) ? oview("[size_x]x[size_y]", ref) : orange("[size_x]x[size_y]", ref)

		for(var/turf/T in turfs)
			var
				display_y = 1 + -(T.y - focus_y)
				display_x = 1 +  (T.x - focus_x)
		/*
			if(display_y < 1 || display_y > size_y)
				continue
			if(display_x < 1 || display_x > size_x)
				continue
		*/
			display[display_y][display_x] = T
		return display

mob/proc
	FormatMap(size_x = 20, size_y = 10)
		if(client.client_type == CLIENT_TELNET)
			var/turf/T = loc
			var/list/L = DrawMap(size_x, size_y, src, 1)

			. += "\[1;37m+\[0;37m[Center("\[1;37m\[\[0;36m[T.name]\[1;37m\]\[0;37m", "-", size_x + 28)]\[1;37m+\[0m\n"
			for(var/Y = 1 to size_y)
				. += "\[0;37m|"
				for(var/X = 1 to size_x)
					//world << "[X],[Y]"
					var/turf/t = L[Y][X]
					if(!t)
						. += " "
					else if(t == loc)
						. += "\[0;37m@\[0m"
					else
						. += "\[0;[t._text]\[0m"
				. += "\[0;37m|\n"
			. += "\[1;37m+[Fill("", "-", size_x)]\[1;37m+\[0m\n"
			. += "\[0;37m\[\[0m[T.x]X,[T.y]Y,[T.z]Z\[0;37m]\[0m\n"

			if(color_manager)
				. += color_manager.Colorize("[T.desc]\n[T.DescribeExits(src)][T.DescribeContents(src)]", CLIENT_TELNET)
			else
				. += "[T.desc]\n[T.DescribeExits(src)][T.DescribeContents(src)]"

			SendTxt(., src, DT_MISC, 0)

		else
			var/turf/T = loc
			. += (color_manager) ? color_manager.Colorize("[T.desc]\n[T.DescribeExits(src)][T.DescribeContents(src)]", CLIENT_DS) : \
									"[T.desc]\n[T.DescribeExits(src)][T.DescribeContents(src)]"
			SendTxt(., src, DT_MISC, 0)


/*
	Worldmap(size, _x, _y, _z)
		var
			upper_x = _x + size
			upper_y = _y + size
			count   = 0
			map_len = (size*2) + 1
			map[map_len]

		for(var/y = _y - size, y <= upper_y, y++)
			count++
			for(var/x = _x - size, x <= upper_x, x++)
				if(x == _x && y == _y)
					map[(map_len+1) - count] += "\[1;31;41m[world_map.map[x][y][_z]]"
				else
					map[(map_len+1) - count] += world_map.map[x][y][_z]
		return map

var/world_map/world_map
world_map
	var/list/map[100][100][5]

	New()
		..()
		// Pad map.
		for(var/x = 1, x <= 100, x++)
			for(var/y = 1, y <= 100, y++)
				for(var/z = 1, z <= 5, z++)
					map[x][y][z] = "\[34;44m~"

	proc
		AddChunk(_x, _y, _z, T)
			map[_x][_y][_z] = T

		ClearChunk(_x, _y, _z)
			map[_x][_y][_z] = " "

		GetText(_x, _y, _z)
			return map[_x][_y][_z]

		GetSegment(x1,y1,x2,y2,z)
			var/list_len = y2 - y1 + 1 // 12
			var/initial_y = y1 // 10
			var/list/L[list_len]
			for(var/y = y1, y <= y2, y++)
				for(var/x = x1, x <= x2, x++)
					L[list_len - (y - initial_y)] += map[x][y][z]
			return L*/