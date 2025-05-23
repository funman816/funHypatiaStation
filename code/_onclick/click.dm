/*
	Click code cleanup
	~Sayu
*/

// 1 decisecond click delay (above and beyond mob/next_move)
/mob/var/next_click	= 0

/*
	Before anything else, defer these calls to a per-mobtype handler.  This allows us to
	remove istype() spaghetti code, but requires the addition of other handler procs to simplify it.

	Alternately, you could hardcode every mob's variation in a flat ClickOn() proc; however,
	that's a lot of code duplication and is hard to maintain.

	Note that this proc can be overridden, and is in the case of screen objects.
*/
/atom/Click(location, control, params)
	usr.ClickOn(src, params)
/atom/DblClick(location, control, params)
	usr.DblClickOn(src,params)

/*
	Standard mob ClickOn()
	Handles exceptions: Buildmode, middle click, modified clicks, mech actions

	After that, mostly just check your state, check whether you're holding an item,
	check whether you're adjacent to the target, then pass off the click to whoever
	is recieving it.
	The most common are:
	* mob/UnarmedAttack(atom,adjacent) - used here only when adjacent, with no item in hand; in the case of humans, checks gloves
	* atom/attackby(item,user) - used only when adjacent
	* item/afterattack(atom,user,adjacent,params) - used both ranged and adjacent
	* mob/RangedAttack(atom,params) - used only ranged, only used for tk and laser eyes but could be changed
*/
/mob/proc/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(client.buildmode)
		build_click(src, client.buildmode, params, A)
		return

	var/list/modifiers = params2list(params)
	if(modifiers["middle"])
		MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(stat || paralysis || stunned || weakened)
		return

	face_atom(A) // change direction to face what you clicked on

	if(next_move > world.time) // in the year 2000...
		return

	if(ismecha(loc))
		if(!locate(/turf) in list(A, A.loc)) // Prevents inventory from being drilled
			return
		var/obj/mecha/M = loc
		return M.click_action(A, src)

	if(restrained())
		RestrainedClickOn(A)
		return

	if(in_throw_mode)
		throw_item(A)
		return

	var/obj/item/W = get_active_hand()

	if(W == A)
		next_move = world.time + 6
		if(HAS_ITEM_FLAGS(W, ITEM_FLAG_HAS_USE_DELAY))
			next_move += 5
		W.attack_self(src)
		if(hand)
			update_inv_l_hand(0)
		else
			update_inv_r_hand(0)

		return

	// operate two STORAGE levels deep here (item in backpack in src; NOT item in box in backpack in src)
	var/sdepth = A.storage_depth(src)
	if(A == loc || (A in loc) || (sdepth != -1 && sdepth <= 1))
		// faster access to objects already on you
		if(A in contents)
			next_move = world.time + 2 // on your person
		else
			next_move = world.time + 4 // in a box/bag or in your square

		// No adjacency needed
		if(isnotnull(W))
			if(HAS_ITEM_FLAGS(W, ITEM_FLAG_HAS_USE_DELAY))
				next_move += 5

			var/resolved = W.handle_attack(A, src)
			if(!resolved && isnotnull(A) && isnotnull(W))
				W.afterattack(A, src, 1, params) // 1 indicates adjacency
		else
			UnarmedAttack(A)
		return

	if(!isturf(loc)) // This is going to stop you from telekinesing from inside a closet, but I don't shed many tears for that
		return

	// Allows you to click on a box's contents, if that box is on the ground, but no deeper than that
	sdepth = A.storage_depth_turf()
	if(isturf(A) || isturf(A.loc) || (sdepth != -1 && sdepth <= 1))
		next_move = world.time + 6

		if(A.Adjacent(src)) // see adjacent.dm
			if(isnotnull(W))
				if(HAS_ITEM_FLAGS(W, ITEM_FLAG_HAS_USE_DELAY))
					next_move += 5

				// Return TRUE in handle_attack() to prevent afterattack() effects (when safely moving items for example)
				var/resolved = W.handle_attack(A, src)
				if(!resolved && isnotnull(A) && isnotnull(W))
					W.afterattack(A, src, 1, params) // 1: clicking something Adjacent
			else
				UnarmedAttack(A, 1)
			return
		else // non-adjacent click
			if(isnotnull(W))
				W.afterattack(A, src, 0, params) // 0: not Adjacent
			else
				RangedAttack(A, params)

// Default behavior: ignore double clicks, consider them normal clicks instead
/mob/proc/DblClickOn(atom/A, params)
	ClickOn(A,params)

/*
	Translates into attack_hand, etc.

	Note: proximity_flag here is used to distinguish between normal usage (flag=1),
	and usage when clicking on things telekinetically (flag=0).  This proc will
	not be called at ranged except with telekinesis.

	proximity_flag is not currently passed to attack_hand, and is instead used
	in human click code to allow glove touches only at melee range.
*/
/mob/proc/UnarmedAttack(atom/A, proximity_flag)
	return

/*
	Ranged unarmed attack:

	This currently is just a default for all mobs, involving
	laser eyes and telekinesis.  You could easily add exceptions
	for things like ranged glove touches, spitting alien acid/neurotoxin,
	animals lunging, etc.
*/
/mob/proc/RangedAttack(atom/A, params)
	if(!length(mutations))
		return
	if((LASER in mutations) && a_intent == "harm")
		LaserEyes(A) // moved into a proc below
	else if(MUTATION_TELEKINESIS in mutations)
		switch(get_dist(src, A))
			if(0)
				;
			if(1 to 5) // not adjacent may mean blocked by window
				next_move += 2
			if(5 to 7)
				next_move += 5
			if(8 to TK_MAXRANGE)
				next_move += 10
			else
				return
		A.attack_tk(src)

/*
	Restrained ClickOn

	Used when you are handcuffed and click things.
	Not currently used by anything but could easily be.
*/
/mob/proc/RestrainedClickOn(atom/A)
	return

/*
	Middle click
	Only used for swapping hands
*/
/mob/proc/MiddleClickOn(atom/A)
	return

/mob/living/carbon/MiddleClickOn(atom/A)
	swap_hand()

// In case of use break glass
/*
/atom/proc/MiddleClick(var/mob/M as mob)
	return
*/

/*
	Misc helpers

	Laser Eyes: as the name implies, handles this since nothing else does currently
	face_atom: turns the mob towards what you clicked on
*/
/mob/proc/LaserEyes(atom/A)
	return

/mob/living/LaserEyes(atom/A)
	next_move = world.time + 6
	var/turf/T = GET_TURF(src)
	var/turf/U = GET_TURF(A)

	var/obj/item/projectile/energy/beam/LE = new /obj/item/projectile/energy/beam(loc)
	LE.icon = 'icons/effects/genetics.dmi'
	LE.icon_state = "eyelasers"
	playsound(usr.loc, 'sound/weapons/gun/taser2.ogg', 75, 1)

	LE.firer = src
	LE.def_zone = get_organ_target()
	LE.original = A
	LE.current = T
	LE.yo = U.y - T.y
	LE.xo = U.x - T.x
	spawn(1)
		LE.process()

/mob/living/carbon/human/LaserEyes()
	if(nutrition > 0)
		..()
		nutrition = max(nutrition - rand(1, 5), 0)
		handle_regular_hud_updates()
	else
		to_chat(src, SPAN_WARNING("You're out of energy! You need food!"))

// Simple helper to face what you clicked on, in case it should be needed in more than one place
/mob/proc/face_atom(atom/A)
	if(buckled || isnull(A) || !x || !y || !A.x || !A.y || (stat && !isghost(src)))
		return

	var/dx = A.x - x
	var/dy = A.y - y
	if(!dx && !dy)
		return

	if(abs(dx) < abs(dy))
		if(dy > 0)
			usr.set_dir(NORTH)
		else
			usr.set_dir(SOUTH)
	else
		if(dx > 0)
			usr.set_dir(EAST)
		else
			usr.set_dir(WEST)