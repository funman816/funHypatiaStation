/*
//////////////////////////////////////

Weight Gain

	Very Very Noticable.
	Decreases resistance.
	Decreases stage speed.
	Reduced transmittable.
	Intense Level.

Bonus
	Increases the weight gain of the mob,
	forcing it to eventually turn fat.
//////////////////////////////////////
*/
/datum/symptom/weight_gain
	name = "Weight Gain"
	stealth = -3
	resistance = -3
	stage_speed = -2
	transmittable = -2
	level = 4

/datum/symptom/weight_gain/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/C = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				to_chat(C, SPAN_NOTICE("[pick("You feel blubbery.", "You feel full.")]"))
			else
				C.overeatduration = min(C.overeatduration + 100, 600)
				C.nutrition = min(C.nutrition + 100, 500)


/*
//////////////////////////////////////

Weight Loss

	Very Very Noticable.
	Decreases resistance.
	Decreases stage speed.
	Reduced Transmittable.
	High level.

Bonus
	Decreases the weight of the mob,
	forcing it to be skinny.

//////////////////////////////////////
*/
/datum/symptom/weight_loss
	name = "Weight Loss"
	stealth = -3
	resistance = -2
	stage_speed = -2
	transmittable = -2
	level = 3

/datum/symptom/weight_loss/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/C = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				to_chat(C, SPAN_NOTICE("[pick("You feel hungry.", "You crave for food.")]"))
			else
				to_chat(C, SPAN_NOTICE("Your stomach rumbles."))
				C.overeatduration = max(C.overeatduration - 100, 0)
				C.nutrition = max(C.nutrition - 100, 0)


/*
//////////////////////////////////////

Weight Even

	Very Noticable.
	Decreases resistance.
	Decreases stage speed.
	Reduced transmittable.
	High level.

Bonus
	Causes the weight of the mob to
	be even, meaning eating isn't
	required anymore.

//////////////////////////////////////
*/
/datum/symptom/weight_even
	name = "Weight Even"
	stealth = -3
	resistance = -2
	stage_speed = -2
	transmittable = -2
	level = 4

/datum/symptom/weight_loss/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/C = A.affected_mob
		switch(A.stage)
			if(4, 5)
				C.overeatduration = 0
				C.nutrition = 400