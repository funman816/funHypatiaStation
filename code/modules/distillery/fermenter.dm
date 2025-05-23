// II. The fermenter is intended to be loaded with food items and returns medium-strength alcohol items, sucha s wine and beer.
/obj/machinery/fermenter
	name = "fermenter"
	desc = "It is a machine that ferments produce into alcoholic drinks."
	icon = 'icons/obj/machines/fabricators/autolathe.dmi'
	icon_state = "autolathe"
	density = TRUE
	anchored = TRUE

	power_usage = alist(
		USE_POWER_IDLE = 10,
		USE_POWER_ACTIVE = 500
	)

	var/list/obj/item/reagent_holder/food/input = list()
	var/list/obj/item/reagent_holder/food/output = list()
	var/obj/item/reagent_holder/food/fermenting_item
	var/water_level = 0
	var/busy = 0
	var/progress = 0
	var/error = 0

/obj/machinery/fermenter/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/reagent_holder/food))
		user.u_equip(W)
		W.forceMove(src)
		input += W
	else
		..()

/obj/machinery/fermenter/attack_hand(mob/user)
	for(var/obj/item/reagent_holder/food/F in output)
		F.forceMove(loc)
		output -= F

/obj/machinery/fermenter/process()
	if(error)
		return

	if(!busy)
		update_power_state(USE_POWER_IDLE)
		if(length(input))
			fermenting_item = input[1]
			input -= fermenting_item
			progress = 0
			busy = 1
			update_power_state(USE_POWER_ACTIVE)
		return

	if(!water_level)
		return

	water_level--

	progress++
	if(progress < FERMENTER_MAX_PROGRESS)
		return	//Not done yet.

	switch(fermenting_item.type)
		if(/obj/item/reagent_holder/food/snacks/flour)	//Flour is still flour
			var/obj/item/reagent_holder/food/drinks/cans/beer/B = new(src)
			output += B
		else
			error = 1

	qdel(fermenting_item)
	busy = 0