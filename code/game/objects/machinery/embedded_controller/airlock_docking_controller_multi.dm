// Adds docking controllers to go alongside airlock controllers, I couldn't be bothered to write these...
// But couldn't port it from a newer distro either... It was good I then remembered/found an older one...
// Ported this from an old Heaven's Gate - Eternal github I found, 22/11/2019. -Frenjo

//a controller for a docking port with multiple independent airlocks
//this is the master controller, that things will try to dock with.
/obj/machinery/embedded_controller/radio/docking_port_multi
	name = "docking port controller"

	var/child_tags_txt
	var/child_names_txt
	var/list/child_names = list()

	var/datum/computer/file/embedded_program/docking/multi/docking_program

/obj/machinery/embedded_controller/radio/docking_port_multi/initialise()
	. = ..()
	docking_program = new /datum/computer/file/embedded_program/docking/multi(src)
	program = docking_program

	var/list/names = splittext(child_names_txt, ";")
	var/list/tags = splittext(child_tags_txt, ";")

	if(length(names) == length(tags))
		for(var/i = 1; i <= length(tags); i++)
			child_names[tags[i]] = names[i]

/obj/machinery/embedded_controller/radio/docking_port_multi/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE)
	var/list/airlocks[length(child_names)]
	var/i = 1
	for(var/child_tag in child_names)
		airlocks[i++] = alist(
			"name" = child_names[child_tag],
			"override_enabled" = (docking_program.children_override[child_tag] == "enabled")
		)

	var/alist/data = alist(
		"docking_status" = docking_program.get_docking_status(),
		"airlocks" = airlocks
	)

	ui = global.PCnanoui.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(isnull(ui))
		ui = new /datum/nanoui(user, src, ui_key, "multi_docking_console.tmpl", name, 470, 290)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update()

/obj/machinery/embedded_controller/radio/docking_port_multi/Topic(href, href_list)
	return



//a docking port based on an airlock
/obj/machinery/embedded_controller/radio/airlock/docking_port_multi
	name = "docking port controller"
	var/master_tag	//for mapping
	var/datum/computer/file/embedded_program/airlock/multi_docking/airlock_program
	tag_secure = 1

/obj/machinery/embedded_controller/radio/airlock/docking_port_multi/initialise()
	. = ..()
	airlock_program = new /datum/computer/file/embedded_program/airlock/multi_docking(src)
	program = airlock_program

/obj/machinery/embedded_controller/radio/airlock/docking_port_multi/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = TRUE)
	var/alist/data = alist(
		"chamber_pressure" = round(airlock_program.memory["chamber_sensor_pressure"]),
		"exterior_status" = airlock_program.memory["exterior_status"],
		"interior_status" = airlock_program.memory["interior_status"],
		"processing" = airlock_program.memory["processing"],
		"docking_status" = airlock_program.master_status,
		"airlock_disabled" = (airlock_program.docking_enabled && !airlock_program.override_enabled),
		"override_enabled" = airlock_program.override_enabled
	)

	ui = global.PCnanoui.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(isnull(ui))
		ui = new /datum/nanoui(user, src, ui_key, "docking_airlock_console.tmpl", name, 470, 290)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update()

/obj/machinery/embedded_controller/radio/airlock/docking_port_multi/Topic(href, href_list)
	if(..())
		return

	usr.set_machine(src)
	src.add_fingerprint(usr)

	var/clean = 0
	switch(href_list["command"])	//anti-HTML-hacking checks
		if("cycle_ext")
			clean = 1
		if("cycle_int")
			clean = 1
		if("force_ext")
			clean = 1
		if("force_int")
			clean = 1
		if("abort")
			clean = 1
		if("toggle_override")
			clean = 1

	if(clean)
		program.receive_user_command(href_list["command"])

	return 1



/*** DEBUG VERBS ***

/datum/computer/file/embedded_program/docking/multi/proc/print_state()
	to_world("id_tag: [id_tag]")
	to_world("dock_state: [dock_state]")
	to_world("control_mode: [control_mode]")
	to_world("tag_target: [tag_target]")
	to_world("response_sent: [response_sent]")

/datum/computer/file/embedded_program/docking/multi/post_signal(datum/signal/signal, comm_line)
	to_world("Program [id_tag] sent a message!")
	print_state()
	to_world("[id_tag] sent command \"[signal.data["command"]]\" to \"[signal.data["recipient"]]\"")
	..(signal)

/obj/machinery/embedded_controller/radio/docking_port_multi/verb/view_state()
	set category = PANEL_DEBUG
	set src in view(1)

	src.program:print_state()

/obj/machinery/embedded_controller/radio/docking_port_multi/verb/spoof_signal(var/command as text, var/sender as text)
	set category = PANEL_DEBUG
	set src in view(1)

	var/datum/signal/signal = new /datum/signal()
	signal.data["tag"] = sender
	signal.data["command"] = command
	signal.data["recipient"] = id_tag

	src.program:receive_signal(signal)

/obj/machinery/embedded_controller/radio/docking_port_multi/verb/debug_init_dock(var/target as text)
	set category = PANEL_DEBUG
	set src in view(1)

	src.program:initiate_docking(target)

/obj/machinery/embedded_controller/radio/docking_port_multi/verb/debug_init_undock()
	set category = PANEL_DEBUG
	set src in view(1)

	src.program:initiate_undocking()
*/
