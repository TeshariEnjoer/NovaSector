/datum/reagent/toxin/n4
	name = "N-4 spores"
	description = "A bioengineered pathogen developed by V.O.I.D., consisting of microscopic spores with a spectral signature. \
					Designed for airborne and contact transmission, it infiltrates organic tissue, initiating silent cellular  \
					degradation to propagate the N-4 Voidplague."
	color = "#440b49"
	taste_description = "chemical decay"
	taste_mult = 1.2
	chemical_flags = REAGENT_IGNORE_STASIS | REAGENT_INVISIBLE
	metabolization_rate = REAGENTS_METABOLISM * 15
	toxpwr = 0
	liver_damage_multiplier = 0
	liver_tolerance_multiplier = 0
	silent_toxin = TRUE
	penetrates_skin = INHALE

/datum/reagent/toxin/n4/on_mob_life(mob/living/carbon/affected_mob, seconds_per_tick, times_fired)
	. = ..()
	var/obj/item/organ/lungs/lungs = affected_mob.get_organ_slot(ORGAN_SLOT_LUNGS)
	// Can't infect is there no lungs or lungs isn't organic
	if(!lungs)
		return
	if(!(lungs.organ_flags & ORGAN_ORGANIC))
		return
	if(affected_mob.reagents.has_reagent(/datum/reagent/medicine/spaceacillin))
		return
	if(SPT_PROB(30, seconds_per_tick))
		affected_mob.emote("Cough")
	if(SPT_PROB(15, seconds_per_tick) && !affected_mob.HasDisease(/datum/disease/n4))
		affected_mob.ForceContractDisease(new /datum/disease/n4(), FALSE, TRUE)
