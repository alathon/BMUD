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

/* Clients own the password, not the mob. */ 
client
	var
		__password

	proc
		// TODO: Hash password?
		__passwordify(n)
			return n

		setPassword(n)
			__password = __passwordify(n)

		isPassword(p)
			return __password == __passwordify(p)
