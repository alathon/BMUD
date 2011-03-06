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

queue/lifo
	var
		list/items=new()

	proc
		contains(datum/D)
			var/idx = items.Find(D)
			if(!idx) return null
			else return items[idx]

		pop()
			var/l = length(items)
			if(!l) return null
			var/datum/A = items[length(items)]
			items.len--
			return A

		push(datum/A)
			if(!items.Find(A)) items.Add(A)

		remove(datum/A)
			return items.Remove(A)
