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
