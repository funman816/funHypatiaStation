/*	Photography!
 *	Contains:
 *		Camera
 *		Camera Film
 *		Photos
 *		Photo Albums
 */

/*******
* film *
*******/
/obj/item/camera_film
	name = "film cartridge"
	icon = 'icons/obj/items.dmi'
	desc = "A camera film cartridge. Insert it into a camera to reload it."
	icon_state = "film"
	item_state = "electropack"
	w_class = 1.0

/********
* photo *
********/
/obj/item/photo
	name = "photo"
	icon = 'icons/obj/items.dmi'
	icon_state = "photo"
	item_state = "paper"
	w_class = 1.0
	var/icon/img	//Big photo image
	var/scribble	//Scribble on the back.

/obj/item/photo/attack_self(mob/user)
	examine(user)

/obj/item/photo/attackby(obj/item/P, mob/user)
	if(istype(P, /obj/item/pen) || istype(P, /obj/item/toy/crayon))
		var/txt = sanitize(input(user, "What would you like to write on the back?", "Photo Writing", null) as text)
		txt = copytext(txt, 1, 128)
		if(loc == user && user.stat == CONSCIOUS)
			scribble = txt
	..()

/obj/item/photo/examine()
	set src in oview(1)
	if(in_range(usr, src))
		show(usr)
		usr << desc
	else
		to_chat(usr, SPAN_NOTICE("It is too far away."))

/obj/item/photo/proc/show(mob/user)
	user << browse_rsc(img, "tmp_photo.png")
	user << browse("<html><head><title>[name]</title></head>" \
		+ "<body style='overflow:hidden'>" \
		+ "<div> <img src='tmp_photo.png' width = '180'" \
		+ "[scribble ? "<div> Written on the back:<br><i>[scribble]</i>" : null]"\
		+ "</body></html>", "window=book;size=200x[scribble ? 400 : 200]")
	onclose(user, "[name]")
	return

/obj/item/photo/verb/rename()
	set category = PANEL_OBJECT
	set name = "Rename photo"
	set src in usr

	var/n_name = copytext(sanitize(input(usr, "What would you like to label the photo?", "Photo Labelling", null) as text), 1, MAX_NAME_LEN)
	//loc.loc check is for making possible renaming photos in clipboards
	if(((loc == usr || (loc.loc && loc.loc == usr)) && usr.stat == CONSCIOUS))
		name = "photo[(n_name ? text("- '[n_name]'") : null)]"
	add_fingerprint(usr)
	return

/**************
* photo album *
**************/
/obj/item/storage/photo_album
	name = "Photo album"
	icon = 'icons/obj/items.dmi'
	icon_state = "album"
	item_state = "briefcase"
	can_hold = list(/obj/item/photo)

/obj/item/storage/photo_album/MouseDrop(obj/over_object)
	if((ishuman(usr) || IS_GAME_MODE(/datum/game_mode/monkey)))
		var/mob/M = usr
		if(!(istype(over_object, /atom/movable/screen)))
			return ..()
		playsound(loc, "rustle", 50, 1, -5)
		if((!(M.restrained()) && !(M.stat) && M.back == src))
			switch(over_object.name)
				if("r_hand")
					M.u_equip(src)
					M.put_in_r_hand(src)
				if("l_hand")
					M.u_equip(src)
					M.put_in_l_hand(src)
			add_fingerprint(usr)
			return
		if(over_object == usr && in_range(src, usr) || usr.contents.Find(src))
			if(usr.s_active)
				usr.s_active.close(usr)
			show_to(usr)
			return
	return

/*********
* camera *
*********/
/obj/item/camera
	name = "camera"
	icon = 'icons/obj/items.dmi'
	desc = "A polaroid camera. 10 photos left."
	icon_state = "camera"
	item_state = "electropack"
	w_class = 2.0
	obj_flags = OBJ_FLAG_CONDUCT
	slot_flags = SLOT_BELT
	matter_amounts = alist(/decl/material/plastic = 2000)

	var/pictures_max = 10
	var/pictures_left = 10
	var/on = 1
	var/icon_on = "camera"
	var/icon_off = "camera_off"

/obj/item/camera/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/camera/attack_self(mob/user)
	on = !on
	if(on)
		src.icon_state = icon_on
	else
		src.icon_state = icon_off
	user << "You switch the camera [on ? "on" : "off"]."
	return

/obj/item/camera/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/camera_film))
		if(pictures_left)
			to_chat(user, SPAN_NOTICE("[src] still has some film in it!"))
			return
		to_chat(user, SPAN_NOTICE("You insert [I] into [src]."))
		user.drop_item()
		qdel(I)
		pictures_left = pictures_max
		return
	..()

/obj/item/camera/proc/get_icon(turf/the_turf)
	//Bigger icon base to capture those icons that were shifted to the next tile
	//i.e. pretty much all wall-mounted machinery
	var/icon/res = icon('icons/effects/96x96.dmi', "")

	var/icon/turficon = build_composite_icon(the_turf)
	res.Blend(turficon, ICON_OVERLAY, 33, 33)

	var/list/atoms = list()
	for(var/atom/A in the_turf)
		if(A.invisibility)
			continue
		atoms.Add(A)

	//Sorting icons based on levels
	var/gap = length(atoms)
	var/swapped = 1
	while(gap > 1 || swapped)
		swapped = 0
		if(gap > 1)
			gap = round(gap / 1.247330950103979)
		if(gap < 1)
			gap = 1
		for(var/i = 1; gap + i <= length(atoms); i++)
			var/atom/l = atoms[i]		//Fucking hate
			var/atom/r = atoms[gap+i]	//how lists work here
			if(l.layer > r.layer)		//no "atoms[i].layer" for me
				atoms.Swap(i, gap + i)
				swapped = 1

	for(var/i; i <= length(atoms); i++)
		var/atom/A = atoms[i]
		if(A)
			var/icon/img = getFlatIcon(A, A.dir)//build_composite_icon(A)
			if(istype(img, /icon))
				res.Blend(new/icon(img, "", A.dir), ICON_OVERLAY, 33 + A.pixel_x, 33 + A.pixel_y)
	return res

/obj/item/camera/proc/get_mobs(turf/the_turf)
	var/mob_detail
	for(var/mob/living/carbon/A in the_turf)
		if(A.invisibility)
			continue
		var/holding = null
		if(A.l_hand || A.r_hand)
			if(A.l_hand)
				holding = "They are holding \a [A.l_hand]"
			if(A.r_hand)
				if(holding)
					holding += " and \a [A.r_hand]"
				else
					holding = "They are holding \a [A.r_hand]"

		if(!mob_detail)
			mob_detail = "You can see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]. "
		else
			mob_detail += "You can also see [A] on the photo[A:health < 75 ? " - [A] looks hurt":""].[holding ? " [holding]":"."]."
	return mob_detail

/obj/item/camera/afterattack(atom/target, mob/user, flag)
	if(!on || !pictures_left || ismob(target.loc))
		return

	var/x_c = target.x - 1
	var/y_c = target.y + 1
	var/z_c	= target.z

	var/icon/temp = icon('icons/effects/96x96.dmi',"")
	var/icon/black = icon('icons/turf/space.dmi', "black")
	var/mobs = ""
	for(var/i = 1; i <= 3; i++)
		for(var/j = 1; j <= 3; j++)
			var/turf/T = locate(x_c, y_c, z_c)
			var/mob/dummy = new(T)	//Go go visibility check dummy
			var/viewer = user
			if(user.client)		//To make shooting through security cameras possible
				viewer = user.client.eye
			if(dummy in viewers(world.view, viewer))
				temp.Blend(get_icon(T), ICON_OVERLAY, 32 * (j-1-1), 32 - 32 * (i-1))
			else
				temp.Blend(black, ICON_OVERLAY, 32 * (j-1), 64 - 32 * (i-1))
			mobs += get_mobs(T)
			dummy.forceMove(null)
			dummy = null	//Alas, nameless creature	//garbage collect it instead
			x_c++
		y_c--
		x_c = x_c - 3

	var/obj/item/photo/P = new/obj/item/photo()
	P.forceMove(user.loc)
	if(!user.get_inactive_hand())
		user.put_in_inactive_hand(P)
	var/icon/small_img = icon(temp)
	var/icon/ic = icon('icons/obj/items.dmi',"photo")
	small_img.Scale(8, 8)
	ic.Blend(small_img,ICON_OVERLAY, 10, 13)
	P.icon = ic
	P.img = temp
	P.desc = mobs
	P.pixel_x = rand(-10, 10)
	P.pixel_y = rand(-10, 10)
	playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, 1, -3)

	pictures_left--
	desc = "A polaroid camera. It has [pictures_left] photos left."
	to_chat(user, SPAN_NOTICE("[pictures_left] photos left."))
	icon_state = icon_off
	on = 0
	spawn(64)
		icon_state = icon_on
		on = 1