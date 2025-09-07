// AI Controller
/datum/ai_controller/basic_controller/n4_mutant
	ai_movement = /datum/ai_movement/basic_avoidance
	idle_behavior = /datum/idle_behavior/idle_random_walk
	blackboard = list(
		BB_TARGETING_STRATEGY = /datum/targeting_strategy/basic,
		BB_TARGET_MINIMUM_STAT = HARD_CRIT,
		BB_MINIMUM_VIEW_DISTANCE = 12,
		BB_CONSUME_LIMBS_MAX = 3,
		BB_CONSUME_LIMBS_CURRENT = 0,
		BB_LAST_TARGET_TIME = 0,
		BB_EXTENDED_HUNT_RANGE = 80,
	)
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/extended_find_distance_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/targeted_mob_ability/consume_limbs,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/mutant,
	)
	movement_delay = 0.3 SECONDS


/datum/ai_planning_subtree/extended_find_distance_target
	var/search_range = 40
	var/extended_delay = 30 SECONDS

/datum/ai_planning_subtree/extended_find_distance_target/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	. = ..()
	if(world.time <= controller.blackboard[BB_LAST_TARGET_TIME] + extended_delay)
		controller.queue_behavior(/datum/ai_behavior/find_potential_targets/most_wounded, BB_BASIC_MOB_CURRENT_TARGET, BB_TARGETING_STRATEGY, BB_BASIC_MOB_CURRENT_TARGET_HIDING_LOCATION)
		return

	search_range = controller.blackboard[BB_EXTENDED_HUNT_RANGE]
	controller.queue_behavior(/datum/ai_behavior/find_distant_target, BB_BASIC_MOB_CURRENT_TARGET, search_range)


/datum/ai_behavior/find_distant_target/perform(seconds_per_tick, datum/ai_controller/controller, hunting_target_key, hunt_range)
	var/mob/living/mutant = controller.pawn
	var/list/possible_targets = list()

	for(var/mob/living/carbon/human/human in orange(hunt_range, mutant))
		if(human.z != mutant.z)
			continue
		var/distance = get_dist(mutant, human)
//		if(!human.client || !human.mind)
//			continue
		if(!valid_target(mutant, human, hunt_range, controller, seconds_per_tick))
			continue
		possible_targets += list(list("target" = human, "priority" = distance))

	if(!length(possible_targets))
		controller.blackboard[BB_LAST_TARGET_TIME] = world.time
		return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_FAILED

	possible_targets = sortTim(possible_targets, /proc/cmp_list_distance_asc)

	var/list/closest_target = possible_targets[1]
	controller.set_blackboard_key(hunting_target_key, closest_target["target"])
	controller.blackboard[BB_CONSUME_LIMBS_CURRENT] = 0
	return AI_BEHAVIOR_DELAY | AI_BEHAVIOR_SUCCEEDED


/proc/cmp_list_distance_asc(list/a, list/b)
	return a["priority"] - b["priority"]


/datum/ai_behavior/find_distant_target/proc/valid_target(mob/living/source, mob/living/carbon/human/human_target, \
													hunt_range, datum/ai_controller/controller, seconds_per_tick)
	var/minimum_view_distance = controller.blackboard[BB_MINIMUM_VIEW_DISTANCE] ? controller.blackboard[BB_MINIMUM_VIEW_DISTANCE] : 12
	if(can_see(source, human_target, min(hunt_range, minimum_view_distance)))
		return TRUE
	if(human_target.stat >= HARD_CRIT)
		return FALSE
	if(human_target.move_intent == MOVE_INTENT_WALK)
		return FALSE
	return TRUE





// В finish_action для melee_attack или других behaviors, добавьте при потере цели:
	// if(!succeeded)
	// 	controller.blackboard[BB_LAST_TARGET_TIME] = world.time

// Abilites

/datum/ai_planning_subtree/targeted_mob_ability/consume_limbs
	ability_key = BB_N4_MUTANT_CONSUME
	finish_planning = FALSE

/datum/ai_planning_subtree/targeted_mob_ability/consume_limbs/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!target)
		return
	if(get_dist(controller.pawn, target) > 1)
		return

	var/is_downed = (target.stat != CONSCIOUS)
	var/current_count = controller.blackboard[BB_CONSUME_LIMBS_CURRENT]
	var/max_count = controller.blackboard[BB_CONSUME_LIMBS_MAX]

	if(is_downed && current_count < max_count)
		controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability, ability_key, BB_BASIC_MOB_CURRENT_TARGET)
		var/new_val = controller.blackboard[BB_CONSUME_LIMBS_CURRENT] + 1
		controller.set_blackboard_key(BB_CONSUME_LIMBS_CURRENT, new_val)
		return
	else if(is_downed && current_count >= max_count)
		controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
		controller.blackboard[BB_CONSUME_LIMBS_CURRENT] = 0
		return


/datum/ai_planning_subtree/basic_melee_attack_subtree/mutant
	melee_attack_behavior = /datum/ai_behavior/basic_melee_attack/after_distant_find

/datum/ai_behavior/basic_melee_attack/after_distant_find


/datum/ai_behavior/basic_melee_attack/after_distant_find/finish_action(datum/ai_controller/controller, succeeded, target_key, targeting_strategy_key, hiding_location_key)
	. = ..()
	if(!succeeded)
		controller.blackboard[BB_LAST_TARGET_TIME] = world.time
