/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\olc\olc.dm

*/

/*

Notes>

	* Abstract saving/loading from the main OLC engine, such that you can hotswap between DMCGI and savefiles
	* Seperate input functions from doing functions, such that OLC can be called and used by DMCGI applications.

    - [ ] OLC System
        - [ ] Obj Editor
        - [ ] Mob Editor
        - [ ] Turf Editor
        - [ ] Zone Editor
        - [ ] DMCGI Support

*/

/*

Zones:

Zome ID (Autoincrease Unsigned Smallint)
Zone Name (VARCHAR, 20)
Zone Welcome Message (VARCHAR, 100)
Zone Move Factor (Unsigned Smallint)
Zone Description (VARCHAR, 100)
Zone SwapmapID (Swapmap ID reference)
Zone Instanced (1 or 0)
*/

/*
Turfs:

id 		(Autoincrease biiig number)
x 		(unsigned smallint)
y 		(unsigned smallint)
z 		(unsigned smallint)
zone_id (Unsigned Smallint)
name	(varchar 20)
desc	(varchar 200)
move_factor (unsigned smallint)

Mobs:

id			(Autoincrease biiig number)
name		(varchar 20)
keywords 	(varchar 100)
gender		(enum 1, 'm' or 'f')
zone_id		(unsigned smallint)
x			(unsigned smallint)
y			(unsigned smallint)
z			(unsigned smallint)

*/

