/* Morgue stuff
 * Contains:
 *		Morgue
 *		Morgue Trays
 *		Crematorium
 *		Crematorium Trays
 *		Crematorium Switches
 */

/*
 * Morgue
 */
/obj/structure/morgue
	name = "morgue"
	desc = "Used to keep bodies in untill someone fetches them."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue1"
	dir = EAST
	density = TRUE
	anchored = TRUE

	var/obj/structure/m_tray/connected = null

/obj/structure/morgue/proc/update()
	if(src.connected)
		src.icon_state = "morgue0"
	else
		if(length(contents))
			src.icon_state = "morgue2"
		else
			src.icon_state = "morgue1"
	return

/obj/structure/morgue/ex_act(severity)
	switch(severity)
		if(1.0)
			for_no_type_check(var/atom/movable/mover, src)
				mover.forceMove(loc)
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for_no_type_check(var/atom/movable/mover, src)
					mover.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if(prob(5))
				for_no_type_check(var/atom/movable/mover, src)
					mover.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return
	return

/obj/structure/morgue/alter_health()
	return src.loc

/obj/structure/morgue/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/structure/morgue/attack_hand(mob/user)
	if(src.connected)
		for(var/atom/movable/A as mob|obj in src.connected.loc)
			if(!A.anchored)
				A.forceMove(src)
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		//src.connected = null
		qdel(src.connected)
	else
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		src.connected = new /obj/structure/m_tray(src.loc)
		step(src.connected, src.dir)
		src.connected.layer = OBJ_LAYER
		var/turf/T = get_step(src, src.dir)
		if(T.contents.Find(src.connected))
			src.connected.connected = src
			src.icon_state = "morgue0"
			for_no_type_check(var/atom/movable/mover, src)
				mover.forceMove(connected.loc)
			src.connected.icon_state = "morguet"
			src.connected.set_dir(src.dir)
		else
			//src.connected = null
			qdel(src.connected)
	src.add_fingerprint(user)
	update()
	return

/obj/structure/morgue/attackby(obj/item/P, mob/user)
	if(istype(P, /obj/item/pen))
		var/t = input(user, "What would you like the label to be?", src.name, null) as text
		if(user.get_active_hand() != P)
			return
		if(!in_range(src, user) && src.loc != user)
			return
		t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
		if(t)
			src.name = "Morgue - '[t]'"
		else
			src.name = "Morgue"
	src.add_fingerprint(user)
	return

/obj/structure/morgue/relaymove(mob/user)
	if(user.stat)
		return
	src.connected = new /obj/structure/m_tray(src.loc)
	step(src.connected, EAST)
	src.connected.layer = OBJ_LAYER
	var/turf/T = get_step(src, EAST)
	if(T.contents.Find(src.connected))
		src.connected.connected = src
		src.icon_state = "morgue0"
		for_no_type_check(var/atom/movable/mover, src)
			mover.forceMove(connected.loc)
			//Foreach goto(106)
		src.connected.icon_state = "morguet"
	else
		//src.connected = null
		qdel(src.connected)
	return

/*
 * Morgue Tray
 */
/obj/structure/m_tray
	name = "morgue tray"
	desc = "Apply corpse before closing."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morguet"
	density = TRUE
	layer = 2.0
	anchored = TRUE
	throwpass = TRUE

	var/obj/structure/morgue/connected = null

/obj/structure/m_tray/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/structure/m_tray/attack_hand(mob/user)
	if(src.connected)
		for(var/atom/movable/A as mob|obj in src.loc)
			if(!A.anchored)
				A.forceMove(connected)
			//Foreach goto(26)
		src.connected.connected = null
		src.connected.update()
		add_fingerprint(user)
		//SN del(src)
		qdel(src)
		return
	return

/obj/structure/m_tray/MouseDrop_T(atom/movable/O, mob/user)
	if(!ismovable(O) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src) || user.contents.Find(O))
		return
	if(!ismob(O) && !istype(O, /obj/structure/closet/body_bag))
		return
	if(!ismob(user) || user.stat || user.lying || user.stunned)
		return
	O.forceMove(loc)
	if(user != O)
		for(var/mob/B in viewers(user, 3))
			if(B.client && !B.blinded)
				to_chat(B, SPAN_WARNING("[user] stuffs [O] into [src]!"))
	return

/*
 * Crematorium
 */
/obj/structure/crematorium
	name = "crematorium"
	desc = "A human incinerator. Works well on barbeque nights."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "crema1"
	density = TRUE
	anchored = TRUE

	var/obj/structure/c_tray/connected = null
	var/cremating = FALSE
	var/id = 1
	var/locked = FALSE

/obj/structure/crematorium/proc/update()
	if(src.connected)
		src.icon_state = "crema0"
	else
		if(length(contents))
			src.icon_state = "crema2"
		else
			src.icon_state = "crema1"
	return

/obj/structure/crematorium/ex_act(severity)
	switch(severity)
		if(1.0)
			for_no_type_check(var/atom/movable/mover, src)
				mover.forceMove(loc)
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				for_no_type_check(var/atom/movable/mover, src)
					mover.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if(prob(5))
				for_no_type_check(var/atom/movable/mover, src)
					mover.forceMove(loc)
					ex_act(severity)
				qdel(src)
				return
	return

/obj/structure/crematorium/alter_health()
	return src.loc

/obj/structure/crematorium/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/structure/crematorium/attack_hand(mob/user)
//	if (cremating) AWW MAN! THIS WOULD BE SO MUCH MORE FUN ... TO WATCH
//		user.show_message("\red Uh-oh, that was a bad idea.", 1)
//		//usr << "Uh-oh, that was a bad idea."
//		src:loc:poison += 20000000
//		src:loc:firelevel = src:loc:poison
//		return
	if(cremating)
		to_chat(user, SPAN_WARNING("It's locked."))
		return
	if(src.connected && !src.locked)
		for(var/atom/movable/A as mob|obj in src.connected.loc)
			if(!A.anchored)
				A.forceMove(src)
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		//src.connected = null
		qdel(src.connected)
	else if(!src.locked)
		playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
		src.connected = new /obj/structure/c_tray(src.loc)
		step(src.connected, SOUTH)
		src.connected.layer = OBJ_LAYER
		var/turf/T = get_step(src, SOUTH)
		if(T.contents.Find(src.connected))
			src.connected.connected = src
			src.icon_state = "crema0"
			for_no_type_check(var/atom/movable/mover, src)
				mover.forceMove(connected.loc)
			src.connected.icon_state = "cremat"
		else
			//src.connected = null
			qdel(src.connected)
	src.add_fingerprint(user)
	update()

/obj/structure/crematorium/attackby(obj/item/P, mob/user)
	if(istype(P, /obj/item/pen))
		var/t = input(user, "What would you like the label to be?", src.name, null) as text
		if(user.get_active_hand() != P)
			return
		if(!in_range(src, user) > 1 && src.loc != user)
			return
		t = copytext(sanitize(t), 1, MAX_MESSAGE_LEN)
		if(t)
			src.name = "Crematorium - '[t]'"
		else
			src.name = "Crematorium"
	src.add_fingerprint(user)
	return

/obj/structure/crematorium/relaymove(mob/user)
	if(user.stat || locked)
		return
	src.connected = new /obj/structure/c_tray(src.loc)
	step(src.connected, SOUTH)
	src.connected.layer = OBJ_LAYER
	var/turf/T = get_step(src, SOUTH)
	if(T.contents.Find(src.connected))
		src.connected.connected = src
		src.icon_state = "crema0"
		for_no_type_check(var/atom/movable/mover, src)
			mover.forceMove(connected.loc)
			//Foreach goto(106)
		src.connected.icon_state = "cremat"
	else
		//src.connected = null
		qdel(src.connected)
	return

/obj/structure/crematorium/proc/cremate(atom/A, mob/user)
//	for(var/obj/machinery/crema_switch/O in src) //trying to figure a way to call the switch, too drunk to sort it out atm
//		if(var/on == 1)
//		return
	if(cremating)
		return //don't let you cremate something twice or w/e

	if(!length(contents))
		for(var/mob/M in viewers(src))
			M.show_message(SPAN_WARNING("You hear a hollow crackle."), 1)
			return

	else
		if(!isemptylist(src.search_contents_for(/obj/item/disk/nuclear)))
			to_chat(user, "You get the feeling that you shouldn't cremate one of the items in the cremator.")
			return

		for(var/mob/M in viewers(src))
			M.show_message(SPAN_WARNING("You hear a roar as the crematorium activates."), 1)

		cremating = TRUE
		locked = TRUE

		for(var/mob/living/M in contents)
			if(M.stat != DEAD)
				M.emote("scream")
			//Logging for this causes runtimes resulting in the cremator locking up. Commenting it out until that's figured out.
			//M.attack_log += "\[[time_stamp()]\] Has been cremated by <b>[user]/[user.ckey]</b>" //No point in this when the mob's about to be deleted
			//user.attack_log +="\[[time_stamp()]\] Cremated <b>[M]/[M.ckey]</b>"
			//log_attack("\[[time_stamp()]\] <b>[user]/[user.ckey]</b> cremated <b>[M]/[M.ckey]</b>")
			M.death(1)
			M.ghostize()
			qdel(M)

		for(var/obj/O in contents) //obj instead of obj/item so that bodybags and ashes get destroyed. We dont want tons and tons of ash piling up
			qdel(O)

		new /obj/effect/decal/cleanable/ash(src)
		sleep(30)
		cremating = FALSE
		locked = FALSE
		playsound(src, 'sound/machines/ding.ogg', 50, 1)
	return

/*
 * Crematorium Tray
 */
/obj/structure/c_tray
	name = "crematorium tray"
	desc = "Apply body before burning."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "cremat"
	density = TRUE
	layer = 2.0
	anchored = TRUE
	throwpass = TRUE

	var/obj/structure/crematorium/connected = null

/obj/structure/c_tray/attack_paw(mob/user)
	return src.attack_hand(user)

/obj/structure/c_tray/attack_hand(mob/user)
	if(src.connected)
		for(var/atom/movable/A as mob|obj in src.loc)
			if(!A.anchored)
				A.forceMove(connected)
			//Foreach goto(26)
		src.connected.connected = null
		src.connected.update()
		add_fingerprint(user)
		//SN del(src)
		qdel(src)
		return
	return

/obj/structure/c_tray/MouseDrop_T(atom/movable/O, mob/user)
	if(!ismovable(O) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src) || user.contents.Find(O))
		return
	if(!ismob(O) && !istype(O, /obj/structure/closet/body_bag))
		return
	if(!ismob(user) || user.stat || user.lying || user.stunned)
		return
	O.forceMove(loc)
	if(user != O)
		for(var/mob/B in viewers(user, 3))
			if(B.client && !B.blinded)
				to_chat(B, SPAN_WARNING("[user] stuffs [O] into [src]!"))
			//Foreach goto(99)
	return

/*
 * Crematorium Switch
 */
/obj/machinery/crema_switch
	desc = "Burn baby burn!"
	name = "crematorium igniter"
	icon = 'icons/obj/power.dmi'
	icon_state = "crema_switch"
	anchored = TRUE
	req_access = list(ACCESS_CREMATORIUM)

	var/on = FALSE
	var/area/area = null
	var/otherarea = null
	var/id = 1

/obj/machinery/crema_switch/attack_hand(mob/user)
	if(src.allowed(user))
		for(var/obj/structure/crematorium/C in GLOBL.movable_atom_list)
			if(C.id == id)
				if(!C.cremating)
					C.cremate(user)
	else
		FEEDBACK_ACCESS_DENIED(user)
	return