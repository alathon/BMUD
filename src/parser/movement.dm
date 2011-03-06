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


mob/proc
	Movement(d)
		var/room/R = src.loc
		var/room/N = R.hasExit(d)
		if(N && istype(N))
			src.Move(N)
		else
			if(client)
				sendTxt("You can't move there.", src, DT_MISC, 0)
