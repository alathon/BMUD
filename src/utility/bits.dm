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
