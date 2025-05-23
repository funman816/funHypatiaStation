
/obj/machinery/bunsen_burner
	name = "bunsen burner"
	desc = "A flat, self-heating device designed for bringing chemical mixtures to boil."
	icon = 'icons/obj/items/devices/device.dmi'
	icon_state = "bunsen0"

	var/heating = 0		//whether the bunsen is turned on
	var/heated = 0		//whether the bunsen has been on long enough to let stuff react
	var/obj/item/reagent_holder/held_container
	var/heat_time = 50

/obj/machinery/bunsen_burner/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/reagent_holder))
		if(held_container)
			to_chat(user, SPAN_WARNING("You must remove the [held_container] first."))
		else
			user.drop_item(src)
			held_container = W
			held_container.forceMove(src)
			to_chat(user, SPAN_INFO("You put the [held_container] onto the [src]."))
			var/image/I = image("icon" = W, "layer" = FLOAT_LAYER)
			underlays += I
			if(heating)
				spawn(heat_time)
					try_heating()
	else
		to_chat(user, SPAN_WARNING("You can't put the [W] onto the [src]."))

/obj/machinery/bunsen_burner/attack_hand(mob/user)
	if(held_container)
		underlays = null
		to_chat(user, SPAN_INFO("You remove the [held_container] from the [src]."))
		held_container.forceMove(loc)
		held_container.attack_hand(user)
		held_container = null
	else
		to_chat(user, SPAN_WARNING("There is nothing on the [src]."))

/obj/machinery/bunsen_burner/proc/try_heating()
	src.visible_message(SPAN_INFO("\icon[src] [src] hisses."))
	if(held_container && heating)
		heated = 1
		held_container.reagents.handle_reactions()
		heated = 0
		spawn(heat_time)
			try_heating()

/obj/machinery/bunsen_burner/verb/toggle()
	set category = PANEL_IC
	set src in view(1)
	set name = "Toggle bunsen burner"

	heating = !heating
	icon_state = "bunsen[heating]"
	if(heating)
		spawn(heat_time)
			try_heating()