/obj/effect/proc_holder/spell/targeted/mind_transfer
	name = "Mind Transfer"
	desc = "This spell allows the user to switch bodies with a target."

	school = "transmutation"
	charge_max = 600
	clothes_req = 0
	invocation = "GIN'YU CAPAN"
	invocation_type = "whisper"
	range = 1

	var/list/protected_roles = list("Wizard", "Changeling", "Cultist") //which roles are immune to the spell
	var/list/compatible_mobs = list(/mob/living/carbon/human, /mob/living/carbon/monkey) //which types of mobs are affected by the spell. NOTE: change at your own risk
	var/base_spell_loss_chance = 20 //base probability of the wizard losing a spell in the process
	var/spell_loss_chance_modifier = 7 //amount of probability of losing a spell added per spell (mind_transfer included)
	var/spell_loss_amount = 1 //the maximum amount of spells possible to lose during a single transfer
	var/msg_wait = 500 //how long in deciseconds it waits before telling that body doesn't feel right or mind swap robbed of a spell
	var/paralysis_amount_caster = 20 //how much the caster is paralysed for after the spell
	var/paralysis_amount_victim = 20 //how much the victim is paralysed for after the spell

/*
Urist: I don't feel like figuring out how you store object spells so I'm leaving this for you to do.
Make sure spells that are removed from spell_list are actually removed and deleted when mind transfering.
Also, you never added distance checking after target is selected. I've went ahead and did that.
*/
/obj/effect/proc_holder/spell/targeted/mind_transfer/cast(list/targets, mob/user = usr)
	if(!length(targets))
		to_chat(user, "No mind found.")
		return

	if(length(targets) > 1)
		to_chat(user, "Too many minds! You're not a hive damnit!")//Whaa...aat?
		return

	var/mob/living/target = targets[1]

	if(!(target in oview(range)))//If they are not in overview after selection. Do note that !() is necessary for in to work because ! takes precedence over it.
		to_chat(user, "They are too far away!")
		return

	if(!(target.type in compatible_mobs))
		to_chat(user, "Their mind isn't compatible with yours.")
		return

	if(target.stat == DEAD)
		to_chat(user, "You didn't study necromancy back at the Space Wizard Federation academy.")
		return

	if(!target.key || !target.mind)
		to_chat(user, "They appear to be catatonic. Not even magic can affect their vacant mind.")
		return

	if(target.mind.special_role in protected_roles)
		to_chat(user, "Their mind is resisting your spell.")
		return

	var/mob/living/victim = target//The target of the spell whos body will be transferred to.
	var/mob/caster = user//The wizard/whomever doing the body transferring.

	//SPELL LOSS BEGIN
	//NOTE: The caster must ALWAYS keep mind transfer, even when other spells are lost.
	var/obj/effect/proc_holder/spell/targeted/mind_transfer/m_transfer = locate() in user.spell_list//Find mind transfer directly.
	var/list/checked_spells = user.spell_list
	checked_spells -= m_transfer //Remove Mind Transfer from the list.

	if(length(caster.spell_list))//If they have any spells left over after mind transfer is taken out. If they don't, we don't need this.
		for(var/i = spell_loss_amount, (i > 0 && length(checked_spells)), i--)//While spell loss amount is greater than zero and checked_spells has spells in it, run this proc.
			for(var/j = length(checked_spells), (j > 0 && length(checked_spells)), j--)//While the spell list to check is greater than zero and has spells in it, run this proc.
				if(prob(base_spell_loss_chance))
					checked_spells -= pick(checked_spells)//Pick a random spell to remove.
					spawn(msg_wait)
						to_chat(victim, "The mind transfer has robbed you of a spell.")
					break//Spell lost. Break loop, going back to the previous for() statement.
				else//Or keep checking, adding spell chance modifier to increase chance of losing a spell.
					base_spell_loss_chance += spell_loss_chance_modifier

	checked_spells += m_transfer//Add back Mind Transfer.
	user.spell_list = checked_spells//Set user spell list to whatever the new list is.
	//SPELL LOSS END

	//MIND TRANSFER BEGIN
	if(length(caster.mind.special_verbs))//If the caster had any special verbs, remove them from the mob verb list.
		for(var/V in caster.mind.special_verbs)//Since the caster is using an object spell system, this is mostly moot.
			caster.verbs -= V//But a safety nontheless.

	if(length(victim.mind.special_verbs))//Now remove all of the victim's verbs.
		for(var/V in victim.mind.special_verbs)
			victim.verbs -= V

	var/mob/dead/ghost/ghost = victim.ghostize(0)
	ghost.spell_list = victim.spell_list//If they have spells, transfer them. Now we basically have a backup mob.

	caster.mind.transfer_to(victim)
	victim.spell_list = caster.spell_list//Now they are inside the victim's body.

	if(length(victim.mind.special_verbs))//To add all the special verbs for the original caster.
		for(var/V in caster.mind.special_verbs)//Not too important but could come into play.
			caster.verbs += V

	ghost.mind.transfer_to(caster)
	caster.key = ghost.key	//have to transfer the key since the mind was not active
	caster.spell_list = ghost.spell_list

	if(length(caster.mind.special_verbs))//If they had any special verbs, we add them here.
		for(var/V in caster.mind.special_verbs)
			caster.verbs += V
	//MIND TRANSFER END

	//Here we paralyze both mobs and knock them out for a time.
	caster.Paralyse(paralysis_amount_caster)
	victim.Paralyse(paralysis_amount_victim)

	//After a certain amount of time the victim gets a message about being in a different body.
	spawn(msg_wait)
		//caster << "<span class='warning'>You feel woozy and lightheaded.</span> <span class='danger'>Your body doesn't seem like your own.</span>"
		to_chat(caster, SPAN_WARNING("You feel woozy and lightheaded."))
		to_chat(caster, SPAN_DANGER("Your body doesn't seem like your own."))