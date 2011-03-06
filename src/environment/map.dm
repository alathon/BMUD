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

// Legacy code to draw ASCII map. Consider revisiting??
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
		var/turf/T = loc
		var/list/L = DrawMap(size_x, size_y, src, 1)

		. += "\[1;37m+\[0;37m[Center("\[1;37m\[\[0;36m[T.name]\[1;37m\]\[0;37m", "-", size_x + 28)]\[1;37m+\[0m\n"
		for(var/Y = 1 to size_y)
			. += "\[0;37m|"
			for(var/X = 1 to size_x)
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

		sendTxt(., src, DT_MISC, 0)
