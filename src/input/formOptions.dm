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

var/formOptions/formOps = new()
formOptions
	var/const
		EXIT_EXIT = -1
		EXIT_DISCONNECT = 0
		EXIT_COMPLETE = 1

	var/const
		STATE_INIT = 1
		STATE_READY = 2
		STATE_WORKING = 3
		STATE_DONE  = 4


