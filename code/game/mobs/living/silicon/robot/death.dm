/mob/living/silicon/robot/dust()
	//Delete the MMI first so that it won't go popping out.
	if(mmi)
		qdel(mmi)
	..()

/mob/living/silicon/robot/death(gibbed)
	if(camera)
		camera.status = 0

	if(model)
		var/obj/item/gripper/G = locate(/obj/item/gripper) in model
		if(G)
			G.drop_item()

	sql_report_cyborg_death(src)

	..(gibbed, "shudders violently for a moment, then becomes motionless, its eyes slowly darkening.")