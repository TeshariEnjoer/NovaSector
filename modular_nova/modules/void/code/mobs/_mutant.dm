/mob/living/basic/n4_mutant
	name = "???"
	icon = 'modular_nova/modules/void/icons/mob/mutants64.dmi'
	health = 250
	maxHealth = 250
	combat_mode = TRUE
	max_stamina = BASIC_MOB_NO_STAMCRIT
	status_flags = CANSTUN
	mob_biotypes = MOB_ORGANIC|MOB_SPECIAL
	layer = LARGE_MOB_LAYER
	can_buckle_to = FALSE
	faction = list(FACTION_VOID, FACTION_HOSTILE) // Be default we freindly with V.O.I.D members
	unsuitable_atmos_damage = 5
	minimum_survivable_temperature = 0
	damage_coeff = list(BRUTE = 0.8, BURN = 0.8, TOX = 0, STAMINA = 0.3, OXY = 0)
	armour_penetration = 30
	melee_damage_upper = 30
	melee_damage_lower = 20

	wound_bonus = DISMEMBER_MINIMUM_DAMAGE
	melee_attack_cooldown = 4 SECONDS


	pixel_x = -16
	pixel_y = -16
	base_pixel_x = -16
	base_pixel_y = -16
	ai_controller = /datum/ai_controller/basic_controller/n4_mutant


/mob/living/basic/n4_mutant/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/relay_attackers)

	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/consume = BB_N4_MUTANT_CONSUME,
	)
	grant_actions_by_list(innate_actions)

	ADD_TRAIT(src, TRAIT_STRENGTH, INNATE_TRAIT)

// Evolved version of mutants

/mob/living/basic/n4_mutant/evolved
	icon = 'modular_nova/modules/void/icons/mob/mutants96.dmi'
	health = 1000
	maxHealth = 1000
	mob_size = MOB_SIZE_HUGE
	layer = LARGE_MOB_LAYER

	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	move_force = MOVE_FORCE_EXTREMELY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	pull_force = MOVE_FORCE_EXTREMELY_STRONG
	obj_damage = 100

	maximum_survivable_temperature = INFINITY

	melee_attack_cooldown = 2 SECONDS
	armour_penetration = 50
	melee_damage_upper = 60
	melee_damage_lower = 40
	wound_bonus = DISMEMBER_MINIMUM_DAMAGE
	unsuitable_atmos_damage = 0

	pixel_x = -32
	pixel_y = -32
	base_pixel_x = -32
	base_pixel_y = -32



/datum/action/cooldown/mob_cooldown/consume
	name = "Consume"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "berserk_mode"
	desc = "Consume limbs of target."

	var/base_amputation_chance = 50

	var/complicated_limb_amputation_chance = 20

	var/base_damage_min = 40

	var/base_damage_max = 60

	var/wound_bonus = 40

	var/do_after_delay = 4 SECONDS
	// Ai only
	var/max_uses_on_down = 3

/datum/action/cooldown/mob_cooldown/consume/Activate(atom/target)
	if(!iscarbon(target))
		return FALSE
	var/mob/living/carbon/carbon_target = target
	if(get_dist(owner, carbon_target) > 1)
		owner.balloon_alert(owner, "too far!")
		return FALSE

	var/amputation_chance = base_amputation_chance
	if(carbon_target.stat != CONSCIOUS)
		amputation_chance += 100

	StartCooldown()
	return perform_decup(carbon_target, amputation_chance)


/datum/action/cooldown/mob_cooldown/consume/proc/perform_decup(mob/living/carbon/target, amputation_chance)
	if(!length(target.bodyparts))
		owner.balloon_alert(owner, "No limbs to consume!")
		return FALSE

	var/list/valid_limbs = list()
	var/list/complicated_limbs = list()
	for(var/obj/item/bodypart/limb in target.bodyparts)
		if(limb.body_zone == BODY_ZONE_CHEST || limb.body_zone == BODY_ZONE_HEAD)
			complicated_limbs += limb
		else
			valid_limbs += limb

	var/obj/item/bodypart/chosen_limb = length(valid_limbs) ? pick(valid_limbs) : pick(complicated_limbs)
	var/is_complicated_limb = (chosen_limb.body_zone == BODY_ZONE_CHEST || chosen_limb.body_zone == BODY_ZONE_HEAD)


	var/effective_amputation_chance = is_complicated_limb ? complicated_limb_amputation_chance : amputation_chance

	owner.visible_message(
		span_danger("[owner] lunges at [target]'s [chosen_limb.name], teeth bared to tear it apart!"),
		span_danger("You sink your teeth into [target]'s [chosen_limb.name]!"),
	)
	playsound(target, 'sound/effects/magic/demon_attack1.ogg', 50, TRUE)
	if(!do_after(owner, do_after_delay, target))
		owner.balloon_alert(owner, "Consumption interrupted!")
		return FALSE


	playsound(target, 'sound/effects/magic/demon_consume.ogg', 75, TRUE)
	owner.balloon_alert(owner, "Consumed [chosen_limb.name]!")

	if(effective_amputation_chance >= 100 || prob(effective_amputation_chance))
		if(!is_complicated_limb)
			chosen_limb.forced_removal(TRUE, TRUE, FALSE)
			target.spawn_gibs()
			owner.visible_message(
				span_danger("[owner] savagely rips [target]'s [chosen_limb.name] clean off!"),
				span_danger("You tear off [target]'s [chosen_limb.name]!"),
			)
			qdel(chosen_limb)
		else
			var/obj/item/organ/to_remove = null
			if(chosen_limb.body_zone == BODY_ZONE_CHEST)
				to_remove = target.get_organ_slot(pick(ORGAN_SLOT_HEART, ORGAN_SLOT_LIVER, ORGAN_SLOT_LUNGS, ORGAN_SLOT_STOMACH))
			else
				to_remove = target.get_organ_slot(pick(ORGAN_SLOT_EARS, ORGAN_SLOT_EYES, ORGAN_SLOT_BRAIN))
			if(to_remove)
				to_remove.bodypart_remove(chosen_limb, target)
				owner.visible_message(
					span_danger("[owner] tears out [target]'s [to_remove.name] with a sickening crunch!"),
					span_danger("You rip out [target]'s [to_remove.name]!"),
				)
				target.spawn_gibs()
			else
				target.apply_damage(rand(base_damage_min * 1.5, base_damage_max * 1.5), BRUTE, chosen_limb.body_zone, FALSE, wound_bonus = wound_bonus)
	else
		target.apply_damage(rand(base_damage_min, base_damage_max), BRUTE, chosen_limb.body_zone, FALSE, wound_bonus = wound_bonus)
		owner.visible_message(
			span_danger("[owner] brutally mauls [target]'s [chosen_limb.name]!"),
			span_danger("You maul [target]'s [chosen_limb.name]!"),
		)

	return TRUE

/datum/ai_planning_subtree/targeted_mob_ability/consume_limbs
	ability_key = BB_N4_MUTANT_CONSUME
	finish_planning = TRUE

/datum/ai_planning_subtree/targeted_mob_ability/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!target || !iscarbon(target) || target.stat == CONSCIOUS)
		return
	..()


