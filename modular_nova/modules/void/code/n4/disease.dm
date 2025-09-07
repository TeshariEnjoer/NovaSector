#define N4_SPREADING_MODIFIER 1.4
#define N4_FINAL_BREATH (60 SECONDS)
#define N4_FINAL_STAGE_DAMAGE 500

// Organs that possible to infect
#define N4_INFECTED_ORGANS list( \
	ORGAN_SLOT_HEART = /obj/item/organ/heart/n4, \
	ORGAN_SLOT_LIVER = /obj/item/organ/liver/n4, \
	ORGAN_SLOT_LUNGS = /obj/item/organ/lungs/n4, \
	ORGAN_SLOT_STOMACH = /obj/item/organ/stomach/n4, \
)

/datum/disease/n4
	name = "N-4"
	desc = "A sinister bioengineered contagion crafted by V.O.I.D., infused with Voidtech microbes. \
			It ravages the body with unpredictable, devastating symptoms, spreading chaos and decay in its wake."
	form = "Bioengineered Disease"
	agent = "N-4 spores"
	visibility_flags = HIDDEN_SCANNER | HIDDEN_PANDEMIC
	spread_flags = DISEASE_SPREAD_CONTACT_FLUIDS | DISEASE_SPREAD_BLOOD
	stage_prob = 1
	max_stages = 7
	spread_text = "N-4 Miasma, blood, fluids"
	cure_text = "VOIDTECH antiviral serum or trimiroal and modafinil and removal of infected organs"
	viable_mobtypes = list(/mob/living/carbon/human)
	bypasses_immunity = TRUE
	severity = DISEASE_SEVERITY_BIOHAZARD
	process_dead = TRUE
	spreading_modifier = N4_SPREADING_MODIFIER
	cures = list(
			/datum/reagent/medicine/c2/tirimol,
			/datum/reagent/medicine/modafinil,
	)

	COOLDOWN_DECLARE(organ_failure)
	var/pass_final_stage = FALSE
	var/transformation = FALSE
	var/total_pulses = 0


/datum/disease/n4/update_stage(new_stage)
	. = ..()
	if(new_stage == 4)
		to_chat(affected_mob, span_userdanger("Something writhes inside you, clawing at your flesh!"))
		visibility_flags = HIDDEN_SCANNER
		spreading_modifier = spreading_modifier * 0.3
		damage_random_organ(15)
		stage_prob = 1
	else if(new_stage == 5)
		visibility_flags = NONE
		infect_organ(ORGAN_SLOT_LUNGS)

/datum/disease/n4/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	if(transformation)
		return transformation_tick(seconds_per_tick)

	// Passing all symptoms due to the final breath
	if(pass_final_stage)
		return TRUE
	switch(stage)
		if(1)
			if(SPT_PROB(0.9, seconds_per_tick))
				affected_mob.emote("cough")

			if(SPT_PROB(1.4, seconds_per_tick))
				to_chat(affected_mob, span_warning("A dull ache throbs faintly in your chest."))
		if(2)
			if(SPT_PROB(1.8, seconds_per_tick))
				to_chat(affected_mob, span_warning("Sharp pain stabs at your insides!"))

			if(SPT_PROB(2, seconds_per_tick))
				affected_mob.emote("cough")
		if(3)
			if(SPT_PROB(2.5, seconds_per_tick))
				to_chat(affected_mob, span_warning("Burning agony pulses through your body!"))

			if(SPT_PROB(1.2, seconds_per_tick))
				affected_mob.adjustOxyLoss(rand(5, 10))
		if(4)
			if(SPT_PROB(3, seconds_per_tick))
				to_chat(affected_mob, span_userdanger("Your flesh trembles as organs begin to decay!"))
				damage_random_organ(rand(10, 15))

			if(SPT_PROB(1.5, seconds_per_tick))
				affected_mob.adjustBruteLoss(rand(3, 6), FALSE)

			if(SPT_PROB(1, seconds_per_tick))
				affected_mob.vomit(VOMIT_CATEGORY_BLOOD)
		if(5)
			if(SPT_PROB(4, seconds_per_tick))
				to_chat(affected_mob, span_userdanger("Your organs writhe, rotting from within!"))
				damage_random_organ(rand(15, 25))

			if(SPT_PROB(2.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Your breath unleashes a deadly miasma!"))
				spread_miasma()

			if(SPT_PROB(1.5, seconds_per_tick))
				infect_organ()

			if(SPT_PROB(2, seconds_per_tick))
				affected_mob.adjustBruteLoss(rand(5, 10), FALSE)
		if(6)
			if(SPT_PROB(2, seconds_per_tick))
				infect_organ()

			if(SPT_PROB(3, seconds_per_tick) && total_infected_organs() >= 1)
				affected_mob.adjustBruteLoss(rand(7, 12), FALSE)
				affected_mob.vomit(VOMIT_CATEGORY_BLOOD)

			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_userdanger("Your organs crumble, consumed by festering decay!"))
				damage_random_organ(rand(20, 30))

			if(SPT_PROB(2, seconds_per_tick))
				to_chat(affected_mob, span_danger("A toxic miasma pours from your lungs!"))
				spread_miasma()

			if(SPT_PROB(3, seconds_per_tick))
				affected_mob.adjustOxyLoss(rand(10, 20))

		if(7)
			if(SPT_PROB(4, seconds_per_tick) && total_infected_organs() >= 2)
				affected_mob.adjustBruteLoss(rand(10, 18), FALSE)
				affected_mob.vomit(VOMIT_CATEGORY_BLOOD)
				to_chat(affected_mob, span_userdanger("Your flesh ruptures, overwhelmed by decay!"))

			if(SPT_PROB(2.5, seconds_per_tick))
				to_chat(affected_mob, span_danger("Your breath unleashes a deadly miasma!"))
				spread_miasma()

			if(total_infected_organs() <= 3)
				return TRUE

			to_chat(affected_mob, span_boldnotice("The decay seems to pause, but your rotting organs shudder with their final, deceitful breaths!"))
			visibility_flags = HIDDEN_SCANNER | HIDDEN_PANDEMIC
			pass_final_stage = TRUE
			addtimer(CALLBACK(src, PROC_REF(enter_transformation)), N4_FINAL_BREATH, (TIMER_UNIQUE|TIMER_OVERRIDE))


/datum/disease/n4/proc/transformation_tick(seconds_per_tick)
	var/direction = pick(NORTH, WEST, EAST, SOUTH, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	affected_mob.Shake(10, 10)
	affected_mob.spray_blood(direction, rand(2, 3))
	total_pulses++

	if(total_pulses > 7)
		release()
		return FALSE
	return TRUE

/datum/disease/n4/cure(add_resistance)
	if(total_infected_organs() > 0)
		return

	if(pass_final_stage)
		return
	return ..()

/datum/disease/n4/proc/enter_transformation()
	to_chat(affected_mob, span_userdanger("Your flesh erupts, consumed by the N-4 Voidplague!"))
	affected_mob.visible_message(
		span_smalldanger("[affected_mob]'s flesh tears apart, their body convulsing and numbing as a monstrous form begins to emerge!"))
	affected_mob.Paralyze(15 SECONDS)
	affected_mob.KnockToFloor(TRUE, TRUE)
	affected_mob.StaminaKnockdown(60, TRUE, TRUE)
	transformation = TRUE

/datum/disease/n4/proc/get_affected_possible_organs()
	var/list/possible_organs = list()
	for(var/obj/item/organ/o in affected_mob.organs)
		if(o.organ_flags & ORGAN_ORGANIC)
			possible_organs += o
	if(length(possible_organs) == 0)
		return
	return possible_organs

/datum/disease/n4/proc/total_infected_organs()
	var/total = 0
	for(var/obj/item/organ/o in affected_mob.organs)
		if(HAS_TRAIT(o, ORGAN_N4_CORRUPTED))
			total++
	return total

/datum/disease/n4/proc/damage_random_organ(damage = 0)
	if(affected_mob.stat == DEAD)
		return
	var/obj/item/organ/o = pick(get_affected_possible_organs())
	if(!o)
		return
	if(damage == 0)
		damage = rand(10, 20)
	o.apply_organ_damage(damage)
	if(o.organ_flags & ORGAN_FAILING)
		infect_organ(o.slot, TRUE)

/datum/disease/n4/proc/spread_miasma()
	var/obj/item/organ/lungs/lungs = affected_mob.get_organ_slot(ORGAN_SLOT_LUNGS)
	if(!lungs || !HAS_TRAIT(lungs, ORGAN_N4_CORRUPTED))
		return FALSE

	var/datum/reagents/reagents = new(15)
	reagents.my_atom = affected_mob
	reagents.add_reagent(/datum/reagent/toxin/n4, 15)
	var/datum/effect_system/fluid_spread/smoke/chem/smoke = new()
	smoke.set_up(1, 2, holder = affected_mob, location = get_turf(affected_mob), carry = reagents)
	smoke.start()
	affected_mob.emote("cough")
	return TRUE

/datum/disease/n4/proc/infect_organ(slot, force = FALSE)
	if(!COOLDOWN_FINISHED(src, organ_failure) && !force)
		return

	var/obj/item/organ/to_replace = null
	var/obj/item/organ/to_insert = null
	if(!slot)
		to_replace = pick(get_affected_possible_organs())
		if(!to_replace)
			return
		to_insert = N4_INFECTED_ORGANS[to_replace.slot]
	else
		to_replace = affected_mob.get_organ_slot(slot)
		to_insert = N4_INFECTED_ORGANS[slot]

	if(!to_insert)
		return

	to_insert = new to_insert()
	if(!to_replace || to_insert.type == to_replace.type)
		qdel(to_insert)
		return

	to_chat(affected_mob, span_userdanger("Your [to_replace.name] rots from within, writhing with decay!"))
	to_insert.Insert(affected_mob, TRUE, DELETE_IF_REPLACED)
	COOLDOWN_START(src, organ_failure, 40 SECONDS)
	affected_mob.vomit(VOMIT_CATEGORY_BLOOD)


/datum/disease/n4/proc/release()
	log_virus("[key_name(affected_mob)] was disintegrated by N-4 at [loc_name(affected_mob)]")
	affected_mob.investigate_log("has been disintegrated by N-4 Voidplague.", INVESTIGATE_DEATHS)

	sleep(1 SECONDS)
	affected_mob.apply_damage(N4_FINAL_STAGE_DAMAGE, BRUTE, forced = TRUE, \
							spread_damage = TRUE, wound_bonus = 80, wound_clothing = FALSE)
	affected_mob.spill_organs(DROP_ORGANS)

#undef N4_INFECTED_ORGANS
#undef N4_SPREADING_MODIFIER
#undef N4_FINAL_BREATH
#undef N4_FINAL_STAGE_DAMAGE
