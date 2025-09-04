#define N4_SPREADING_MODIFIER 1.4
#define N4_FINAL_BREATH (25 SECONDS)
#define N4_FINAL_STAGE_DAMAGE 500

/datum/disease/n4
	name = "N-4"
	desc = "A sinister bioengineered contagion crafted by V.O.I.D., infused with Voidtech microbes. \
			It ravages the body with unpredictable, devastating symptoms, spreading chaos and decay in its wake."
	form = "Bioengineered Disease"
	agent = "N-4 microbes"
	visibility_flags = HIDDEN_SCANNER | HIDDEN_PANDEMIC
	stage_prob = 0.5
	max_stages = 7
	spread_text = "Unknown"
	viable_mobtypes = list(/mob/living/carbon/human)
	bypasses_immunity = TRUE
	severity = DISEASE_SEVERITY_BIOHAZARD
	process_dead = TRUE
	spreading_modifier = N4_SPREADING_MODIFIER
	cures = list(/datum/reagent/medicine/c2/penthrite)

	COOLDOWN_DECLARE(organ_failure)
	var/static/list/infected_organs = list(
		ORGAN_SLOT_HEART = /obj/item/organ/heart/n4,
		ORGAN_SLOT_LIVER = /obj/item/organ/liver/n4,
		ORGAN_SLOT_LUNGS = /obj/item/organ/lungs/n4,
		ORGAN_SLOT_STOMACH = /obj/item/organ/stomach/n4,
	)


	var/passed_full_absorbation = FALSE
	var/transformation = FALSE
	var/total_pulses = 0


/datum/disease/n4/update_stage(new_stage)
	. = ..()
	if(new_stage == 4)
		to_chat(affected_mob, span_userdanger("Something writhes inside you, clawing at your flesh!"))
		visibility_flags = HIDDEN_SCANNER
		spreading_modifier = spreading_modifier * 0.3
		damage_random_organ(15)
	else if(new_stage == 5)
		visibility_flags = NONE
		infect_organ(ORGAN_SLOT_LUNGS)

	else if(new_stage == 7)

/datum/disease/n4/stage_act(seconds_per_tick, times_fired)
	. = ..()
	if(!.)
		return

	if(transformation)
		return transformation_tick(seconds_per_tick)

	// Passing all symphtomps due the final breath's
	if(passed_full_absorbation)
		return TRUE
	switch(stage)
		if(1)
			if(SPT_PROB(0.8, seconds_per_tick))
				affected_mob.emote("cough")
		if(5)
			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_warning("Your organs constrict, crushed by an unseen force!"))
				damage_random_organ()
		if(6)
			if(SPT_PROB(0.3, seconds_per_tick))
				infect_organ()

			if(SPT_PROB(3, seconds_per_tick) && total_infected_organs() >= 2)
				affected_mob.adjustBruteLoss(rand(3, 5), FALSE)
				affected_mob.vomit(VOMIT_CATEGORY_BLOOD)

			if(SPT_PROB(5, seconds_per_tick))
				to_chat(affected_mob, span_warning("Your organs rot!"))
				damage_random_organ()
		if(7)
			if(SPT_PROB(3, seconds_per_tick) && total_infected_organs() >= 2)
				affected_mob.adjustBruteLoss(rand(3, 5), FALSE)
				affected_mob.vomit(VOMIT_CATEGORY_BLOOD)

			if(total_infected_organs() <= 3)
				infect_organ()
				return TRUE

			to_chat(affected_mob, span_notice("The N-4 Voidplague seems to fade, but your rotting organs \
					shudder with their final, deceitful breaths!"))
			visibility_flags = HIDDEN_SCANNER | HIDDEN_PANDEMIC
			passed_full_absorbation = TRUE
			addtimer(CALLBACK(src, PROC_REF(pass_final_stage)), N4_FINAL_BREATH, (TIMER_UNIQUE|TIMER_OVERRIDE))


/datum/disease/n4/proc/transformation_tick(seconds_per_tick)
	var/direction = pick(NORTH, WEST, EAST, SOUTH, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	affected_mob.Shake(10, 10)
	affected_mob.spray_blood(direction, 3)
	total_pulses++

	if(total_pulses > 7)
		release()
		return FALSE

	return TRUE


/datum/disease/n4/cure(add_resistance)
	if(total_infected_organs() > 0)
		return

	if(passed_full_absorbation)
		return
	return ..()

/datum/disease/n4/proc/pass_final_stage()
	to_chat(affected_mob, span_userdanger("Your flesh erupts, consumed by the N-4 Voidplague!"))
	affected_mob.visible_message(
		span_smalldanger("[affected_mob]'s flesh tears apart, their body convulsing and numbing as a monstrous form begins to emerge!"))
	affected_mob.apply_damage(N4_FINAL_STAGE_DAMAGE, BRUTE, forced = TRUE, \
							spread_damage = TRUE, wound_bonus = 100, wound_clothing = FALSE)
	transformation = TRUE

/datum/disease/n4/proc/get_affected_possible_organs()
	var/list/possible_organs = list()
	for(var/obj/item/organ/o in affected_mob.organs)
		if(o.organ_flags & ORGAN_ORGANIC && !(o.organ_flags & ORGAN_N4_CORRUPTED))
			possible_organs += o
	if(length(possible_organs) == 0)
		return
	return possible_organs

/datum/disease/n4/proc/total_infected_organs()
	var/total = 0
	for(var/obj/item/organ/o in infected_organs)
		if(o.organ_flags & ORGAN_N4_CORRUPTED)
			total++
	return total

/datum/disease/n4/proc/damage_random_organ(damage = 0)
	if(affected_mob.stat == DEAD)
		return
	var/obj/item/organ/o = pick(get_affected_possible_organs())
	if(!o)
		return
	if(damage = 0)
		damage = rand(2, 5)
	o.apply_organ_damage(damage)


/datum/disease/n4/proc/infect_organ(slot)
	if(affected_mob.stat == DEAD)
		return
	if(!COOLDOWN_FINISHED(src, organ_failure))
		return

	var/obj/item/organ/to_replace = null
	var/obj/item/organ/to_insert = null
	if(!slot)
		to_replace = pick(get_affected_possible_organs())
		if(!to_replace)
			return
		to_insert = infected_organs[to_replace.slot]
	else
		to_replace = affected_mob.get_organ_slot(slot)
		to_insert = infected_organs[slot]

	if(!to_insert)
		return

	to_insert = new to_insert()
	if(!to_replace || to_insert.type == to_replace.type)
		qdel(to_insert)
		return

	to_chat(affected_mob, span_userdanger("Your [to_replace.name] rots from within, writhing with N-4 decay!"))
	to_insert.Insert(affected_mob, TRUE, DELETE_IF_REPLACED)
	COOLDOWN_START(src, organ_failure, 25 SECONDS)
	affected_mob.vomit(VOMIT_CATEGORY_BLOOD)


/datum/disease/n4/proc/release()
	log_virus("[key_name(affected_mob)] was disintegrated by N-4 at [loc_name(affected_mob)]")
	affected_mob.investigate_log("has been disintegrated by N-4 Voidplague.", INVESTIGATE_DEATHS)
	affected_mob.gib(DROP_ALL_REMAINS)



#undef N4_SPREADING_MODIFIER
#undef N4_FINAL_BREATH
#undef N4_FINAL_STAGE_DAMAGE
