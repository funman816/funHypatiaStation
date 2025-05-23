/obj/item/brain
	name = "brain"
	desc = "A piece of juicy meat found in a persons head."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "brain2"
	force = 1.0
	w_class = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5
	origin_tech = alist(/decl/tech/biotech = 3)
	attack_verb = list("attacked", "slapped", "whacked")

	var/mob/living/brain/brainmob = null

/obj/item/brain/initialise()
	. = ..()
	//Shifting the brain "mob" over to the brain object so it's easier to keep track of. --NEO
	//WASSSSSUUUPPPP /N
	if(brainmob && brainmob.client)
		brainmob.client.screen.len = null //clear the hud

/obj/item/brain/Destroy()
	if(isnotnull(brainmob))
		QDEL_NULL(brainmob)
	return ..()

/obj/item/brain/proc/transfer_identity(var/mob/living/carbon/H)
	name = "[H]'s brain"
	brainmob = new(src)
	brainmob.name = H.real_name
	brainmob.real_name = H.real_name
	brainmob.dna = H.dna.Clone()
	brainmob.timeofhostdeath = H.timeofdeath
	if(H.mind)
		H.mind.transfer_to(brainmob)
	brainmob << "\blue You feel slightly disoriented. That's normal when you're just a brain."
	return

/obj/item/brain/examine() // -- TLE
	set src in oview(12)
	if(!(usr))
		return
	usr << "This is \icon[src] \an [name]."

	if(brainmob && brainmob.client)//if thar be a brain inside... the brain.
		usr << "You can feel the small spark of life still left in this one."
	else
		usr << "This one seems particularly lifeless. Perhaps it will regain some of its luster later.."

/obj/item/brain/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!ismob(M))
		return

	add_fingerprint(user)

	if(!(user.zone_sel.selecting == ("head")) || !ishuman(M))
		return ..()

	if(!(locate(/obj/machinery/optable, M.loc) && M.resting) && (!(locate(/obj/structure/table/, M.loc) && M.lying) && prob(50)))
		return ..()

	if(ishuman(M) && M.are_eyes_covered())
		// you can't stab someone in the eyes wearing a mask!
		user << "\blue You're going to need to remove their head cover first."
		return

//since these people will be dead M != usr

	if(M:brain_op_stage == 4.0)
		for(var/mob/O in viewers(M, null))
			if(O == (user || M))
				continue
			if(M == user)
				O.show_message(SPAN_WARNING("[user] inserts \the [src] into his head!"), 1)
			else
				O.show_message(SPAN_WARNING("[M] has \the [src] inserted into his head by [user]."), 1)

		if(M != user)
			to_chat(M, SPAN_WARNING("[user] inserts \the [src] into your head!"))
			to_chat(user, SPAN_WARNING("You insert \the [src] into [M]'s head!"))
		else
			to_chat(user, SPAN_WARNING("You insert \the [src] into your head!"))

		//this might actually be outdated since barring badminnery, a debrain'd body will have any client sucked out to the brain's internal mob. Leaving it anyway to be safe. --NEO
		if(M.key)//Revised. /N
			M.ghostize()

		if(brainmob.mind)
			brainmob.mind.transfer_to(M)
		else
			M.key = brainmob.key

		M:brain_op_stage = 3.0

		qdel(src)
	else
		..()
	return