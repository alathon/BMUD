/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\core\bits.dm

bits.dm defines a set of bit-shifting related procedures, for ease of use
*/
proc
	is_set(bitflag, value)
		return (bitflag&value)

	set_bit(bitflag, value)
		if(is_set(bitflag,value)) return 1
		bitflag |= value
		return 1

	rem_bit(bitflag, value)
		if(!is_set(bitflag,value)) return 1
		bitflag &= ~value
		return 1

	toggle_bit(bitflag, value)
		bitflag ^= value
		return 1
