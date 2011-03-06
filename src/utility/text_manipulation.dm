/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\core\text_manipulation.dm

Text manipulation procedures, and related.
*/

proc/capitalize(t)
	if(!t) return
	if(length(t)==1) return uppertext(t)

	return "[uppertext(copytext(t,1,2))][lowertext(copytext(t,2))]"

// Thanks to Dan for the next two procedures. They should be self-explanatory in use and function
proc/text2list(txt,delim)
	var
		start = 1
		end = findtext(txt, delim)
		lst[0]

	while(end)
		lst += copytext(txt,start,end)
		start = end+1
		end = findtext(txt,delim,start)
	lst += copytext(txt,start)
	return lst

proc/list2text(lst[],delim)
	var/i
	if(!istype(lst,/list)) return lst
	for(i=1, i<=lst.len, i++)
		. = "[ . ][ lst[i] ][ (i+1>lst.len) ? "" : delim]"

proc
	translateTokens(T,mob/M) // Translates tokens according to values of M
		if(!M) return T

		. = T

		var
			symbol = findtext(., TOKEN_SYMBOL)
			char   = ""

		while(symbol)
			char = copytext(., symbol+1, symbol+2)
			if(symbol == 1)
				switch(char)
					if("n")
						. = "[M.name][copytext(., 3)]"
					if("m")
						. = "[M.gender == "male" ? "him" : "her"][copytext(., 3)]"
					if("h")
						. = "[M.gender == "male" ? "his" : "her"][copytext(., 3)]"
			else
				switch(char)
					if("n")
						. = "[copytext(., 1, symbol)][M.name][copytext(., symbol+2)]"
					if("m")
						. = "[copytext(., 1, symbol)][M.gender == "male" ? "him":"her"][copytext(., symbol+2)]"
					if("h")
						. = "[copytext(., 1, symbol)][M.gender == "male" ? "his":"her"][copytext(., symbol+2)]"
			symbol = findtext(.,TOKEN_SYMBOL,symbol+2)

	// Checks for following syntax:
	// X.item
	// 1st item
	scanNum(string)
		// Chop off number portion
		. = ""
		var/c = text2num(copytext(string, 1, 2))
		var/last_pos = 1
		var/list/r[2]
		while(c)
			last_pos++
			. += "[c]"
			c = text2num(copytext(string, last_pos, last_pos+1))
		. = text2num(.)
		r[1] = . - 1
		if(last_pos > 1 && findtext(string, ".") == last_pos) // Syntax: NNN.Item
			r[2] = last_pos + 1
			return r

		else if("[.]\th" == copytext(string,1,last_pos+2)) // Syntax: 5th item
			r[2] = last_pos + 3
			return r
		else
			return 0

	// "lite" version of above. Only checks for X.item
	scannum(string)
		var/p = findtext(string, ".")
		if(!p) return -1
		return text2num(copytext(string,1,p)) - 1

	fillText(txt,char,l)
		if(isnum(txt)) txt = "[txt]"

		var/L = length(txt)
		if(L == l)
			. = txt
		else if(l < L)
			. = copytext(txt,1,l)
		else
			var/diff = l - L
			var/init = 1
			. = txt
			for(init=1, init <= diff, init++)
				. += char

	matchAtom(string, atom/from, type_specific)
		if(!string || !from) return 0

		var/list/L
		var/list/scan = scanNum(string)
		var/num		  = 0
		if(istype(scan, /list))
			num = scan[1]
			string = copytext(string, scan[2])
			scan = null

		if(istype(from, /atom))
			L = from.contents
		else if(istype(from, /list))
			L = from
		else
			return 0

		for(var/atom/A in L)
			if(A.ParseMatch(string, 1, 1) && (!type_specific || istype(A, type_specific)))
				if(num > 0)
					num--
					continue
				return A
		return null

	centerText(txt, char, l)
		if(isnum(txt)) txt = "[txt]"
		var
			txt_len = length(txt)
			delta_txt = l - txt_len
		. = txt
		if(l < txt_len)
			. = copytext(., 1, l)
			return
		else if(txt_len == l)
			return
		else if(delta_txt == 1)
			return "[.][char]"
		if(delta_txt%2) // Odd number
			. = "[char][.]"
			delta_txt--
		delta_txt /= 2
		var/padding = ""
		for(var/i = 1, i<= delta_txt, i++)
			padding += "[char]"
		. = "[padding][.][padding]"
