/*

Barebones MUD (BMUD) 2.0, by Martin Gielsgaard Grünbaum, 2007

bmud2\objects\datum.dm

Various variables and procedures related to datums
*/

datum
	var
		_uid = 0 // UIDs identify a datum. Beyond type paths, there may be multiple instances of a type path that deviate in variables.
			 // Once a datum is assigned a UID, that UID will not change or ever be taken.
			 // UIDs are contextual according to the type of datum you're referring to. There may be a mob with the same UID
			 // as an obj; however, they are differentiated by their type. You can create several instances of a datum with the
			 // same UID. To differentiate those uniquely, use the \ref of an obj.
			 // TODO: Rename to __uid, and make sure we actually want this at a datum-level ??? Doesn't seem like it.

datum/New(fake = 0)
	if(!fake)
		Log("Created datum: [src.type] (ref=\ref[src])", EVENT_NEWDATUM)

datum/Del(fake = 0)
	if(!fake)
		Log("Deleted datum: [src.type] (ref=\ref[src])", EVENT_DELDATUM)
	..()
