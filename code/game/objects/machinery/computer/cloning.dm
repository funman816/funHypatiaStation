/obj/machinery/computer/cloning
	name = "cloning console"
	icon_state = "dna"
	circuit = /obj/item/circuitboard/cloning
	req_access = list(ACCESS_BRIDGE) //Only used for record deletion right now.

	var/obj/machinery/dna_scannernew/scanner = null //Linked scanner. For scanning.
	var/obj/machinery/clonepod/pod1 = null //Linked cloning pod.
	var/temp = ""
	var/scantemp = "Scanner unoccupied"
	var/menu = 1 //Which menu screen to display
	var/list/records = list()
	var/datum/dna2/record/active_record = null
	var/obj/item/disk/cloning_data/diskette = null //Mostly so the geneticist can steal everything.
	var/loading = 0 // Nice loading text

	light_color = "#315ab4"

/obj/machinery/computer/cloning/New()
	..()
	spawn(5)
		updatemodules()
		return
	return

/obj/machinery/computer/cloning/proc/updatemodules()
	src.scanner = findscanner()
	src.pod1 = findcloner()

	if(isnotnull(src.pod1))
		src.pod1.connected = src // Some variable the pod needs

/obj/machinery/computer/cloning/proc/findscanner()
	var/obj/machinery/dna_scannernew/scannerf = null

	// Loop through every direction
	for(dir in list(NORTH,EAST,SOUTH,WEST))

		// Try to find a scanner in that direction
		scannerf = locate(/obj/machinery/dna_scannernew, get_step(src, dir))

		// If found, then we break, and return the scanner
		if (isnotnull(scannerf))
			break

	// If no scanner was found, it will return null
	return scannerf

/obj/machinery/computer/cloning/proc/findcloner()
	var/obj/machinery/clonepod/podf = null

	for(dir in list(NORTH,EAST,SOUTH,WEST))

		podf = locate(/obj/machinery/clonepod, get_step(src, dir))

		if(isnotnull(podf))
			break

	return podf

/obj/machinery/computer/cloning/attack_by(obj/item/I, mob/user)
	if(istype(I, /obj/item/disk/cloning_data)) //INSERT SOME DISKETTES
		if(isnotnull(diskette))
			to_chat(user, SPAN_WARNING("There is already a disk inserted."))
			return TRUE
		user.drop_item()
		I.forceMove(src)
		diskette = I
		user.visible_message(
			SPAN_INFO("[user] inserts \the [I] into \the [src]."),
			SPAN_INFO("You insert \the [I] into \the [src].")
		)
		updateUsrDialog()
		return TRUE
	return ..()

/obj/machinery/computer/cloning/attack_paw(mob/user)
	return attack_hand(user)

/obj/machinery/computer/cloning/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/computer/cloning/attack_hand(mob/user)
	user.set_machine(src)
	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER))
		return

	updatemodules()

	var/dat = "<h3>Cloning System Control</h3>"
	dat += "<font size=-1><a href='byond://?src=\ref[src];refresh=1'>Refresh</a></font>"

	dat += "<br><tt>[temp]</tt><br>"

	switch(src.menu)
		if(1)
			// Modules
			dat += "<h4>Modules</h4>"
			//dat += "<a href='byond://?src=\ref[src];relmodules=1'>Reload Modules</a>"
			if(isnull(src.scanner))
				dat += " <font color=red>Scanner-ERROR</font><br>"
			else
				dat += " <font color=green>Scanner-Found!</font><br>"
			if(isnull(src.pod1))
				dat += " <font color=red>Pod-ERROR</font><br>"
			else
				dat += " <font color=green>Pod-Found!</font><br>"

			// Scanner
			dat += "<h4>Scanner Functions</h4>"

			if(loading)
				dat += "<b>Scanning...</b><br>"
			else
				dat += "<b>[scantemp]</b><br>"

			if(isnull(src.scanner))
				dat += "No scanner connected!<br>"
			else
				if(src.scanner.occupant)
					if(scantemp == "Scanner unoccupied") scantemp = "" // Stupid check to remove the text

					dat += "<a href='byond://?src=\ref[src];scan=1'>Scan - [src.scanner.occupant]</a><br>"
				else
					scantemp = "Scanner unoccupied"

				dat += "Lock status: <a href='byond://?src=\ref[src];lock=1'>[src.scanner.locked ? "Locked" : "Unlocked"]</a><br>"

			if(isnotnull(src.pod1))
				dat += "Biomass: <i>[src.pod1.biomass]</i><br>"

			// Database
			dat += "<h4>Database Functions</h4>"
			dat += "<a href='byond://?src=\ref[src];menu=2'>View Records</a><br>"
			if (src.diskette)
				dat += "<a href='byond://?src=\ref[src];disk=eject'>Eject Disk</a>"


		if(2)
			dat += "<h4>Current records</h4>"
			dat += "<a href='byond://?src=\ref[src];menu=1'>Back</a><br><br>"
			for(var/datum/dna2/record/R in src.records)
				dat += "<li><a href='byond://?src=\ref[src];view_rec=\ref[R]'>[R.dna.real_name]</a><li>"

		if(3)
			dat += "<h4>Selected Record</h4>"
			dat += "<a href='byond://?src=\ref[src];menu=2'>Back</a><br>"

			if(!src.active_record)
				dat += "<font color=red>ERROR: Record not found.</font>"
			else
				dat += {"<br><font size=1><a href='byond://?src=\ref[src];del_rec=1'>Delete Record</a></font><br>
					<b>Name:</b> [src.active_record.dna.real_name]<br>"}
				var/obj/item/implant/health/H = null
				if(src.active_record.implant)
					H=locate(src.active_record.implant)

				if((H) && (istype(H)))
					dat += "<b>Health:</b> [H.sensehealth()] | OXY-BURN-TOX-BRUTE<br>"
				else
					dat += "<font color=red>Unable to locate implant.</font><br>"

				if(isnotnull(src.diskette))
					dat += "<a href='byond://?src=\ref[src];disk=load'>Load from disk.</a>"

					dat += " | Save: <a href='byond://?src=\ref[src];save_disk=ue'>UI + UE</a>"
					dat += " | Save: <a href='byond://?src=\ref[src];save_disk=ui'>UI</a>"
					dat += " | Save: <a href='byond://?src=\ref[src];save_disk=se'>SE</a>"
					dat += "<br>"
				else
					dat += "<br>" //Keeping a line empty for appearances I guess.

				dat += {"<b>UI:</b> [src.active_record.dna.uni_identity]<br>
				<b>SE:</b> [src.active_record.dna.struc_enzymes]<br><br>"}

				if(pod1 && pod1.biomass >= CLONE_BIOMASS)
					dat += {"<a href='byond://?src=\ref[src];clone=\ref[src.active_record]'>Clone</a><br>"}
				else
					dat += {"<b>Insufficient stem cell charges</b><br>"}

		if(4)
			if(!src.active_record)
				src.menu = 2
			dat = "[src.temp]<br>"
			dat += "<h4>Confirm Record Deletion</h4>"

			dat += "<b><a href='byond://?src=\ref[src];del_rec=1'>Scan card to confirm.</a></b><br>"
			dat += "<b><a href='byond://?src=\ref[src];menu=3'>No</a></b>"


	user << browse(dat, "window=cloning")
	onclose(user, "cloning")
	return

/obj/machinery/computer/cloning/Topic(href, href_list)
	if(..())
		return

	if(loading)
		return

	if((href_list["scan"]) && (isnotnull(src.scanner)))
		scantemp = ""

		loading = 1
		src.updateUsrDialog()

		spawn(20)
			src.scan_mob(src.scanner.occupant)

			loading = 0
			src.updateUsrDialog()


		//No locking an open scanner.
	else if((href_list["lock"]) && (isnotnull(src.scanner)))
		if((!src.scanner.locked) && (src.scanner.occupant))
			src.scanner.locked = 1
		else
			src.scanner.locked = 0

	else if (href_list["view_rec"])
		src.active_record = locate(href_list["view_rec"])
		if(istype(src.active_record,/datum/dna2/record))
			if ((isnull(src.active_record.ckey)))
				qdel(src.active_record)
				src.temp = "ERROR: Record Corrupt"
			else
				src.menu = 3
		else
			src.active_record = null
			src.temp = "Record missing."

	else if (href_list["del_rec"])
		if((!src.active_record) || (src.menu < 3))
			return
		if(src.menu == 3) //If we are viewing a record, confirm deletion
			src.temp = "Delete record?"
			src.menu = 4

		else if (src.menu == 4)
			var/obj/item/card/id/C = usr.get_active_hand()
			if(istype(C)||istype(C, /obj/item/pda))
				if(src.check_access(C))
					src.records.Remove(src.active_record)
					qdel(src.active_record)
					src.temp = "Record deleted."
					src.menu = 2
				else
					src.temp = "Access Denied."

	else if (href_list["disk"]) //Load or eject.
		switch(href_list["disk"])
			if("load")
				if ((isnull(src.diskette)) || isnull(src.diskette.buf))
					src.temp = "Load error."
					src.updateUsrDialog()
					return
				if (isnull(src.active_record))
					src.temp = "Record error."
					src.menu = 1
					src.updateUsrDialog()
					return

				src.active_record = src.diskette.buf

				src.temp = "Load successful."
			if("eject")
				if (isnotnull(src.diskette))
					diskette.forceMove(loc)
					src.diskette = null

	else if (href_list["save_disk"]) //Save to disk!
		if((isnull(src.diskette)) || (src.diskette.read_only) || (isnull(src.active_record)))
			src.temp = "Save error."
			src.updateUsrDialog()
			return

		// DNA2 makes things a little simpler.
		src.diskette.buf=src.active_record
		src.diskette.buf.types=0
		switch(href_list["save_disk"]) //Save as Ui/Ui+Ue/Se
			if("ui")
				src.diskette.buf.types=DNA2_BUF_UI
			if("ue")
				src.diskette.buf.types=DNA2_BUF_UI|DNA2_BUF_UE
			if("se")
				src.diskette.buf.types=DNA2_BUF_SE
		src.diskette.name = "data disk - '[src.active_record.dna.real_name]'"
		src.temp = "Save \[[href_list["save_disk"]]\] successful."

	else if (href_list["refresh"])
		src.updateUsrDialog()

	else if (href_list["clone"])
		var/datum/dna2/record/C = locate(href_list["clone"])
		//Look for that player! They better be dead!
		if(istype(C))
			//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
			if(!pod1)
				temp = "Error: No Clonepod detected."
			else if(pod1.occupant)
				temp = "Error: Clonepod is currently occupied."
			else if(pod1.biomass < CLONE_BIOMASS)
				temp = "Error: Not enough stem cell charges."
			else if(pod1.mess)
				temp = "Error: Clonepod malfunction."
			else if(!CONFIG_GET(/decl/configuration_entry/revival_cloning))
				temp = "Error: Unable to initiate cloning cycle."

			else if(pod1.growclone(C))
				temp = "Initiating cloning cycle..."
				records.Remove(C)
				qdel(C)
				menu = 1
			else

				var/mob/selected = find_dead_player("[C.ckey]")
				selected << 'sound/machines/chime.ogg'	//probably not the best sound but I think it's reasonable
				var/answer = alert(selected,"Do you want to return to life?","Cloning","Yes","No")
				if(answer != "No" && pod1.growclone(C))
					temp = "Initiating cloning cycle..."
					records.Remove(C)
					qdel(C)
					menu = 1
				else
					temp = "Initiating cloning cycle...<br>Error: Post-initialisation failed. Cloning cycle aborted."

		else
			temp = "Error: Data corruption."

	else if (href_list["menu"])
		src.menu = text2num(href_list["menu"])

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/cloning/proc/scan_mob(mob/living/carbon/human/subject)
	if((isnull(subject)) || (!(ishuman(subject))) || (!subject.dna))
		scantemp = "Error: Unable to locate valid genetic data."
		return
	if(!subject.has_brain())
		if(ishuman(subject))
			var/mob/living/carbon/human/H = subject
			if(H.species.has_organ["brain"])
				scantemp = "Error: No signs of intelligence detected."
		else
			scantemp = "Error: No signs of intelligence detected."
		return
	if(subject.suiciding == 1)
		scantemp = "Error: Subject's brain is not responding to scanning stimuli."
		return
	if((!subject.ckey) || (!subject.client))
		scantemp = "Error: Mental interface failure."
		return
	if(MUTATION_NO_CLONE in subject.mutations)
		scantemp = "Error: Mental interface failure."
		return
	if(isnotnull(find_record(subject.ckey)))
		scantemp = "Subject already in database."
		return

	subject.dna.check_integrity()

	var/datum/dna2/record/R = new /datum/dna2/record()
	R.dna = subject.dna
	R.ckey = subject.ckey
	R.id = copytext(md5(subject.real_name), 2, 6)
	R.name = R.dna.real_name
	R.types = DNA2_BUF_UI|DNA2_BUF_UE|DNA2_BUF_SE

	//Add an implant if needed
	var/obj/item/implant/health/imp = locate(/obj/item/implant/health, subject)
	if(isnull(imp))
		imp = new /obj/item/implant/health(subject)
		imp.implanted = subject
		R.implant = "\ref[imp]"
	//Update it if needed
	else
		R.implant = "\ref[imp]"

	if(isnotnull(subject.mind)) //Save that mind so traitors can continue traitoring after cloning.
		R.mind = "\ref[subject.mind]"

	src.records += R
	scantemp = "Subject successfully scanned."

//Find a specific record by key.
/obj/machinery/computer/cloning/proc/find_record(find_key)
	var/selected_record = null
	for(var/datum/dna2/record/R in src.records)
		if (R.ckey == find_key)
			selected_record = R
			break
	return selected_record

/obj/machinery/computer/cloning/update_icon()

	if(stat & BROKEN)
		icon_state = "commb"
	else
		if(stat & NOPOWER)
			src.icon_state = "c_unpowered"
			stat |= NOPOWER
		else
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
