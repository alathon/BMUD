datum/New()
	Log("Created datum: [src.type] (ref=\ref[src])", EVENT_NEWDATUM)

datum/Del(fake = 0)
	Log("Deleted datum: [src.type] (ref=\ref[src])", EVENT_DELDATUM)
	..()
