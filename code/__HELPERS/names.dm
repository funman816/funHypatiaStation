GLOBAL_GLOBL_INIT(command_name, null)
/proc/command_name()
	if(isnotnull(GLOBL.command_name))
		return GLOBL.command_name

	var/name = "Central Command"

	GLOBL.command_name = name
	return name

/proc/change_command_name(name)
	GLOBL.command_name = name

	return name

/proc/station_name()
	if(isnotnull(GLOBL.current_map.station_name))
		return GLOBL.current_map.station_name

	var/random = rand(1, 5)
	var/name = ""

	//Rare: Pre-Prefix
	if(prob(10))
		name = pick("Imperium", "Heretical", "Cuban", "Psychic", "Elegant", "Common", "Uncommon", "Rare", "Unique", "Houseruled", "Religious", "Atheist", "Traditional", "Houseruled", "Mad", "Super", "Ultra", "Secret", "Top Secret", "Deep", "Death", "Zybourne", "Central", "Main", "Government", "Uoi", "Fat", "Automated", "Experimental", "Augmented")
		GLOBL.current_map.station_name = name + " "

	// Prefix
	switch(CONFIG_GET(/decl/configuration_entry/holiday_name))
		//get normal name
		if(null, "", 0)
			name = pick("", "Stanford", "Dorf", "Alium", "Prefix", "Clowning", "Aegis", "Ishimura", "Scaredy", "Death-World", "Mime", "Honk", "Rogue", "MacRagge", "Ultrameens", "Safety", "Paranoia", "Explosive", "Neckbear", "Donk", "Muppet", "North", "West", "East", "South", "Slant-ways", "Widdershins", "Rimward", "Expensive", "Procreatory", "Imperial", "Unidentified", "Immoral", "Carp", "Ork", "Pete", "Control", "Nettle", "Aspie", "Class", "Crab", "Fist","Corrogated","Skeleton","Race", "Fatguy", "Gentleman", "Capitalist", "Communist", "Bear", "Beard", "Derp", "Space", "Spess", "Star", "Moon", "System", "Mining", "Neckbeard", "Research", "Supply", "Military", "Orbital", "Battle", "Science", "Asteroid", "Home", "Production", "Transport", "Delivery", "Extraplanetary", "Orbital", "Correctional", "Robot", "Hats", "Pizza")
			if(name)
				GLOBL.current_map.station_name += name + " "

		//For special days like christmas, easter, new-years etc ~Carn
		if("Friday the 13th")
			name = pick("Mike", "Friday", "Evil", "Myers", "Murder", "Deathly", "Stabby")
			GLOBL.current_map.station_name += name + " "
			random = 13
		else
			//get the first word of the Holiday and use that
			var/i = findtext(CONFIG_GET(/decl/configuration_entry/holiday_name), " ", 1, 0)
			name = copytext(CONFIG_GET(/decl/configuration_entry/holiday_name), 1, i)
			GLOBL.current_map.station_name += name + " "

	// Suffix
	name = pick("Station", "Fortress", "Frontier", "Suffix", "Death-trap", "Space-hulk", "Lab", "Hazard","Spess Junk", "Fishery", "No-Moon", "Tomb", "Crypt", "Hut", "Monkey", "Bomb", "Trade Post", "Fortress", "Village", "Town", "City", "Edition", "Hive", "Complex", "Base", "Facility", "Depot", "Outpost", "Installation", "Drydock", "Observatory", "Array", "Relay", "Monitor", "Platform", "Construct", "Hangar", "Prison", "Center", "Port", "Waystation", "Factory", "Waypoint", "Stopover", "Hub", "HQ", "Office", "Object", "Fortification", "Colony", "Planet-Cracker", "Roost", "Fat Camp")
	GLOBL.current_map.station_name += name + " "

	// ID Number
	switch(random)
		if(1)
			GLOBL.current_map.station_name += "[rand(1, 99)]"
		if(2)
			GLOBL.current_map.station_name += pick("Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu", "Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi", "Chi", "Psi", "Omega")
		if(3)
			GLOBL.current_map.station_name += pick("II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X", "XI", "XII", "XIII", "XIV", "XV", "XVI", "XVII", "XVIII", "XIX", "XX")
		if(4)
			GLOBL.current_map.station_name += pick("Alpha", "Bravo", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet", "Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec", "Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray", "Yankee", "Zulu")
		if(5)
			GLOBL.current_map.station_name += pick("One", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve", "Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen")
		if(13)
			GLOBL.current_map.station_name += pick("13", "XIII", "Thirteen")

	if(isnotnull(CONFIG_GET(/decl/configuration_entry/server_name)))
		world.name = "[CONFIG_GET(/decl/configuration_entry/server_name)]: [name]"
	else
		world.name = GLOBL.current_map.station_name

	return GLOBL.current_map.station_name

/proc/world_name(name)
	GLOBL.current_map.station_name = name

	if(isnotnull(CONFIG_GET(/decl/configuration_entry/server_name)))
		world.name = "[CONFIG_GET(/decl/configuration_entry/server_name)]: [name]"
	else
		world.name = name

	return name

GLOBAL_GLOBL_INIT(syndicate_name, null)
/proc/syndicate_name()
	if(isnotnull(GLOBL.syndicate_name))
		return GLOBL.syndicate_name

	var/name = ""

	// Prefix
	name += pick("Clandestine", "Prima", "Blue", "Zero-G", "Max", "Blasto", "Waffle", "North", "Omni", "Newton", "Cyber", "Bonk", "Gene", "Gib")

	// Suffix
	if(prob(80))
		name += " "

		// Full
		if(prob(60))
			name += pick("Syndicate", "Consortium", "Collective", "Corporation", "Group", "Holdings", "Biotech", "Industries", "Systems", "Products", "Chemicals", "Enterprises", "Family", "Creations", "International", "Intergalactic", "Interplanetary", "Foundation", "Positronics", "Hive")
		// Broken
		else
			name += pick("Syndi", "Corp", "Bio", "System", "Prod", "Chem", "Inter", "Hive")
			name += pick("", "-")
			name += pick("Tech", "Sun", "Co", "Tek", "X", "Inc", "Code")
	// Small
	else
		name += pick("-", "*", "")
		name += pick("Tech", "Sun", "Co", "Tek", "X", "Inc", "Gen", "Star", "Dyne", "Code", "Hive")

	GLOBL.syndicate_name = name
	return name


// Traitors and traitor silicons will get these. Revs will not.
GLOBAL_GLOBL_INIT(syndicate_code_phrase, null)		// Code phrase for traitors.
GLOBAL_GLOBL_INIT(syndicate_code_response, null)	// Code response for traitors.

/*
	Should be expanded.
	How this works:
	Instead of "I'm looking for James Smith," the traitor would say "James Smith" as part of a conversation.
	Another traitor may then respond with: "They enjoy running through the void-filled vacuum of the derelict."
	The phrase should then have the words: James Smith.
	The response should then have the words: run, void, and derelict.
	This way assures that the code is suited to the conversation and is unpredicatable.
	Obviously, some people will be better at this than others but in theory, everyone should be able to do it and it only enhances roleplay.
	Can probably be done through "{ }" but I don't really see the practical benefit.
	One example of an earlier system is commented below.
	/N
*/

/proc/generate_code_phrase()//Proc is used for phrase and response in master_controller.dm
	. = "" //What is returned when the proc finishes.
	var/words = pick(//How many words there will be. Minimum of two. 2, 4 and 5 have a lesser chance of being selected. 3 is the most likely.
		50; 2,
		200; 3,
		50; 4,
		25; 5
	)

	var/list/safety = list(1, 2, 3)//Tells the proc which options to remove later on.
	var/list/nouns = list(
		"love", "hate", "anger", "peace", "pride", "sympathy", "bravery","loyalty", "honesty", "integrity",
		"compassion", "charity", "success", "courage", "deceit", "skill", "beauty", "brilliance", "pain", "misery",
		"beliefs", "dreams", "justice", "truth", "faith", "liberty", "knowledge", "thought", "information", "culture",
		"trust", "dedication", "progress", "education", "hospitality", "leisure", "trouble", "friendships", "relaxation"
	)
	var/list/drinks = list(
		"vodka and tonic", "gin fizz", "bahama mama", "manhattan", "black Russian", "whiskey soda", "long island tea", "margarita",
		"Irish coffee", "manly dwarf", "Irish cream", "doctor's delight", "Beepksy Smash", "tequilla sunrise", "brave bull", "gargle blaster",
		"bloody mary", "whiskey cola", "white Russian", "vodka martini", "martini", "Cuba libre", "kahlua", "vodka", "wine", "moonshine"
	)
	var/list/locations = length(GLOBL.teleportlocs) ? GLOBL.teleportlocs : drinks//if null, defaults to drinks instead.

	var/list/names = list()
	for_no_type_check(var/datum/data/record/t, GLOBL.data_core.general) // Picks from crew manifest.
		names.Add(t.fields["name"])

	var/maxwords = words//Extra var to check for duplicates.

	for(words, words > 0, words--)//Randomly picks from one of the choices below.
		if(words == 1 && (1 in safety) && (2 in safety))//If there is only one word remaining and choice 1 or 2 have not been selected.
			safety = list(pick(1, 2))//Select choice 1 or 2.
		else if(words == 1 && maxwords == 2)//Else if there is only one word remaining (and there were two originally), and 1 or 2 were chosen,
			safety = list(3)//Default to list 3

		switch(pick(safety))//Chance based on the safety list.
			if(1)//1 and 2 can only be selected once each to prevent more than two specific names/places/etc.
				switch(rand(1, 2))//Mainly to add more options later.
					if(1)
						if(length(names) && prob(70))
							. += pick(names)
						else
							. += pick(pick(GLOBL.first_names_male, GLOBL.first_names_female))
							. += " "
							. += pick(GLOBL.last_names)
					if(2)
						. += pick(GLOBL.all_jobs) // Returns a job.
				safety -= 1
			if(2)
				switch(rand(1, 2))//Places or things.
					if(1)
						. += pick(drinks)
					if(2)
						. += pick(locations)
				safety -= 2
			if(3)
				switch(rand(1, 3))//Nouns, adjectives, verbs. Can be selected more than once.
					if(1)
						. += pick(nouns)
					if(2)
						. += pick(GLOBL.adjectives)
					if(3)
						. += pick(GLOBL.verbs)
		if(words == 1)
			. += "."
		else
			. += ", "

/*
//This proc tests the gen above.
/client/verb/test_code_phrase()
	set category = PANEL_DEBUG
	set name = "Generate Code Phrase"

	to_world("\red Code Phrase is: \black [generate_code_phrase()]")
	return


	This was an earlier attempt at code phrase system, aside from an even earlier attempt (and failure).
	This system more or less works as intended--aside from being unfinished--but it's still very predictable.
	Particularly, the phrase opening statements are pretty easy to recognize and identify when metagaming.
	I think the above-used method solves this issue by using words in a sequence, providing for much greater flexibility.
	/N

	switch(choice)
		if(1)
			syndicate_code_phrase += pick("I'm looking for","Have you seen","Maybe you've seen","I'm trying to find","I'm tracking")
			syndicate_code_phrase += " "
			syndicate_code_phrase += pick(pick(first_names_male,first_names_female))
			syndicate_code_phrase += " "
			syndicate_code_phrase += pick(last_names)
			syndicate_code_phrase += "."
		if(2)
			syndicate_code_phrase += pick("How do I get to","How do I find","Where is","Where do I find")
			syndicate_code_phrase += " "
			syndicate_code_phrase += pick("Escape","Engineering","Atmos","the bridge","the brig","Clown Planet","CentCom","the library","the chapel","a bathroom","Med Bay","Tool Storage","the escape shuttle","Robotics","a locker room","the living quarters","the gym","the autolathe","QM","the bar","the theater","the derelict")
			syndicate_code_phrase += "?"
		if(3)
			if(prob(70))
				syndicate_code_phrase += pick("Get me","I want","I'd like","Make me")
				syndicate_code_phrase += " a "
			else
				syndicate_code_phrase += pick("One")
				syndicate_code_phrase += " "
			syndicate_code_phrase += pick("vodka and tonic","gin fizz","bahama mama","manhattan","black Russian","whiskey soda","long island tea","margarita","Irish coffee"," manly dwarf","Irish cream","doctor's delight","Beepksy Smash","tequilla sunrise","brave bull","gargle blaster","bloody mary","whiskey cola","white Russian","vodka martini","martini","Cuba libre","kahlua","vodka","wine","moonshine")
			syndicate_code_phrase += "."
		if(4)
			syndicate_code_phrase += pick("I wish I was","My dad was","His mom was","Where do I find","The hero this station needs is","I'd fuck","I wouldn't trust","Someone caught","HoS caught","Someone found","I'd wrestle","I wanna kill")
			syndicate_code_phrase += " [pick("a","the")] "
			syndicate_code_phrase += pick("wizard","ninja","xeno","lizard","slime","monkey","syndicate","cyborg","clown","space carp","singularity","singulo","mime")
			syndicate_code_phrase += "."
		if(5)
			syndicate_code_phrase += pick("Do we have","Is there","Where is","Where's","Who's")
			syndicate_code_phrase += " "
			syndicate_code_phrase += "[pick(joblist)]"
			syndicate_code_phrase += "?"

	switch(choice)
		if(1)
			if(prob(80))
				syndicate_code_response += pick("Try looking for them near","I they ran off to","Yes. I saw them near","Nope. I'm heading to","Try searching")
				syndicate_code_response += " "
				syndicate_code_response += pick("Escape","Engineering","Atmos","the bridge","the brig","Clown Planet","CentCom","the library","the chapel","a bathroom","Med Bay","Tool Storage","the escape shuttle","Robotics","a locker room","the living quarters","the gym","the autolathe","QM","the bar","the theater","the derelict")
				syndicate_code_response += "."
			else if(prob(60))
				syndicate_code_response += pick("No. I'm busy, sorry.","I don't have the time.","Not sure, maybe?","There is no time.")
			else
				syndicate_code_response += pick("*shrug*","*smile*","*blink*","*sigh*","*laugh*","*nod*","*giggle*")
		if(2)
			if(prob(80))
				syndicate_code_response += pick("Go to","Navigate to","Try","Sure, run to","Try searching","It's near","It's around")
				syndicate_code_response += " the "
				syndicate_code_response += pick("[pick("south","north","east","west")] maitenance door","nearby maitenance","teleporter","[pick("cold","dead")] space","morgue","vacuum","[pick("south","north","east","west")] hall ","[pick("south","north","east","west")] hallway","[pick("white","black","red","green","blue","pink","purple")] [pick("rabbit","frog","lion","tiger","panther","snake","facehugger")]")
				syndicate_code_response += "."
			else if(prob(60))
				syndicate_code_response += pick("Try asking","Ask","Talk to","Go see","Follow","Hunt down")
				syndicate_code_response += " "
				if(prob(50))
					syndicate_code_response += pick(pick(first_names_male,first_names_female))
					syndicate_code_response += " "
					syndicate_code_response += pick(last_names)
				else
					syndicate_code_response += " the "
					syndicate_code_response += "[pic(joblist)]"
				syndicate_code_response += "."
			else
				syndicate_code_response += pick("*shrug*","*smile*","*blink*","*sigh*","*laugh*","*nod*","*giggle*")
		if(3)
		if(4)
		if(5)

	return
*/