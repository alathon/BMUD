/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\core\movement.dm

movement.dm deals with the movement of atoms in the world.
All atoms must move using atom.Move(), which is completely exposed
in the code below and thus modifiable.
*/


// Default Move() procedure done in DM, courtesey of Lummox JR
// Here merely for observational purposes. Commented out as of 07-03-2007,
// and /obj movement moved entirely to obj.MoveTo()
/*
atom/proc/GetDenseObject()

turf/GetDenseObject()
	if(density) return src
	if(loc.density) return loc
	for(var/obj/O in src) if(O.density) return O
	for(var/mob/M in src) if(M.density) return M

atom/Enter()
	return 1

atom/Exit()
	return 1

turf/Enter(atom/movable/A)
	if(!A) return 0
	if(!A.density) return 1
	var/atom/D = GetDenseObject()
	return (!D || D == A) ? 1 : 0

atom/movable/Move(atom/newloc, newdir)
	if(newdir) dir = newdir

    // Move() ignores null destinations so bumping into edge of map has no effect
	if(!newloc)
		return 0

	var/atom/oldloc = loc
	if(loc && newloc && !newdir) dir = get_dir(loc, newloc)
	if(oldloc && !oldloc.Exit(src))
		return 0

	var/area/area1 = oldloc
	var/area/area2 = newloc
	while(area1 && !isarea(area1)) area1 = area1.loc
	while(area2 && !isarea(area2)) area2 = area2.loc

	if(area1 && area1 != area2 && isturf(oldloc) && !area1.Exit(src))
		return 0

	if(newloc && !newloc.Enter(src))
		if(newloc) Bump(newloc.GetDenseObject())
		return 0

	if(area2 && area1 != area2 && isturf(newloc) && !area2.Enter(src))
		if(newloc) Bump(newloc.GetDenseObject())
		return 0

    // if something else moved us already, abort
	if(loc != oldloc)
		return 0
	if(isobj(src))
		var/obj/O = src
		O.MoveTo(newloc)
		if(isobj(newloc))
			newloc:Update()
		else if(isturf(newloc) && O)
			O.text = newloc.text

	else
		loc = newloc

	if(oldloc) oldloc.Exited(src)
	if(area1 && area1 != area2 && !isarea(oldloc))
		area1.Exited(src)
	if(loc) loc.Entered(src, oldloc)
	if(area2 && area1 != area2 && !isarea(loc))
		area2.Entered(src, oldloc)

	return 1
    // end of atom/movable/Move()

mob/Bump(atom/A)
	if(ismob(A))
		var/mob/M = A
		if(src in M.group)
			var/swap = loc
			loc = M.loc
			M.loc = swap
*/