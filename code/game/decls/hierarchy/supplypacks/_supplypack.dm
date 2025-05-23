//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been hacked.
//ANOTHER NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//BIG NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NEW NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.

/decl/hierarchy/supply_pack
	name = "Supply Packs"

	var/list/contains = list()
	var/manifest = ""
	var/amount = null
	var/cost = null
	var/containertype = /obj/structure/closet/crate // Must be an /obj/structure subtype.
	var/containername = null
	var/access = null
	var/hidden = FALSE
	var/contraband = FALSE
	var/num_contained = 0 //number of items picked to be contained in a randomised crate
	var/supply_method = /decl/supply_method

/decl/hierarchy/supply_pack/New()
	. = ..()
	if(is_category())
		return	// Don't init the manifest for category entries

	if(!num_contained)
		for(var/entry in contains)
			num_contained += max(1, contains[entry])

	var/decl/supply_method/sm = GET_DECL_INSTANCE(supply_method)
	manifest = sm.setup_manifest(src)

/decl/hierarchy/supply_pack/proc/spawn_contents(location)
	var/decl/supply_method/sm = GET_DECL_INSTANCE(supply_method)
	return sm.spawn_contents(src, location)

/*
//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been hacked.
//ANOTER NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//BIG NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NEW NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.
*/
/decl/supply_method/proc/spawn_contents(decl/hierarchy/supply_pack/sp, location)
	if(isnull(sp) || isnull(location))
		return
	. = list()
	for(var/entry in sp.contains)
		for(var/i = 1 to max(1, sp.contains[entry]))
			dd_insertObjectList(., new entry(location))

/decl/supply_method/proc/setup_manifest(decl/hierarchy/supply_pack/sp)
	. = list()
	. += "<ul>"
	for(var/path in sp.contains)
		var/atom/A = path
		if(!ispath(A))
			continue
		. += "<li>[initial(A.name)]</li>"
	. += "</ul>"
	. = jointext(., null)

/decl/supply_method/randomised/spawn_contents(decl/hierarchy/supply_pack/sp, location)
	if(isnull(sp) || isnull(location))
		return
	. = list()
	for(var/j = 1 to sp.num_contained)
		var/picked = pick(sp.contains)
		. += new picked(location)

/decl/supply_method/randomised/setup_manifest(decl/hierarchy/supply_pack/sp)
	return "Contains any [sp.num_contained] of:" + ..()

// Supply order datum
/datum/supply_order
	var/ordernum
	var/decl/hierarchy/supply_pack/object = null
	var/orderedby = null
	var/comment = null