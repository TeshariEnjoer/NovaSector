#define BB_N4_LERAPER_TONGUE_GRAB "n4_leaper_tongue_grab"

/mob/living/basic/n4_mutant/evolved/leaper
	name = "X-304 Leaper"
	desc = "At the apex of slaughter demons' savage order, this crowned terror reigns, \
			its blood-soaked throne built on the screams of the damned."
	icon_state = "leaper"
	speed = 5
	lighting_cutoff_red = 30
	lighting_cutoff_green = 15
	lighting_cutoff_blue = 50
	melee_damage_lower = 40
	melee_damage_upper = 50
	attack_verb_continuous = "mauls"
	attack_verb_simple = "maul"

	ai_controller = /datum/ai_controller/basic_controller/n4_mutant/leaper

/mob/living/basic/n4_mutant/evolved/leaper/Initialize(mapload)
	. = ..()
	var/static/list/innate_actions = list(
		/datum/action/cooldown/mob_cooldown/projectile_attack/tongue_grab = BB_N4_LERAPER_TONGUE_GRAB,
	)

	grant_actions_by_list(innate_actions)

/mob/living/basic/n4_mutant/evolved/leaper/examine_more(mob/user)
	. = ..()
	. += span_danger("RUN FROM IT!")

/datum/ai_controller/basic_controller/n4_mutant/leaper
	planning_subtrees = list(
		/datum/ai_planning_subtree/escape_captivity,
		/datum/ai_planning_subtree/simple_find_target,
		/datum/ai_planning_subtree/attack_obstacle_in_path,
		/datum/ai_planning_subtree/targeted_mob_ability/tongue_grab,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,
		/datum/ai_planning_subtree/targeted_mob_ability/consume_limbs,
	)

	movement_delay = 0.3 SECONDS

/datum/ai_planning_subtree/targeted_mob_ability/tongue_grab
	ability_key = BB_N4_LERAPER_TONGUE_GRAB
	finish_planning = FALSE

/datum/ai_planning_subtree/targeted_mob_ability/tongue_grab/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!target)
		return
	var/mob/living/pawn = controller.pawn
	if(get_dist(target, pawn) <= 3)
		return
	..()


/datum/action/cooldown/mob_cooldown/projectile_attack/tongue_grab
	name = "Tongue grab"
	button_icon_state = "Light1"
	background_icon_state = "bg_changeling"
	desc = "Grabs a target to pull it alongside you."
	cooldown_time = 8 SECONDS


	var/grab_pixel_x = 0
	var/grab_pixel_y = 0
	var/grab_distance = 10

	// Time we need to throw someone direct to us
	var/grab_time = 2 SECONDS

/datum/action/cooldown/mob_cooldown/projectile_attack/tongue_grab/Activate(atom/target_atom)
	if(!isliving(target_atom))
		return TRUE
	var/mob/living/victim = target_atom
	if(victim.anchored)
		owner.balloon_alert(owner, "can't pull!")
		return TRUE
	if(get_dist(owner, target_atom) > grab_distance)
		owner.balloon_alert(owner, "too far!")
		return TRUE
	var/list/target_turfs = get_line(owner, target_atom) - list(get_turf(owner), get_turf(target_atom))
	for(var/turf/blockage in target_turfs)
		if(blockage.is_blocked_turf(exclude_mobs = TRUE))
			owner.balloon_alert(owner, "path blocked!")
			return TRUE
	owner.Beam(victim, icon_state = "tentacle", time = grab_time, emissive = FALSE, \
				override_origin_pixel_x = grab_pixel_x, override_origin_pixel_y = grab_pixel_y)
	if(victim.check_block(owner, 0, "", LEAP_ATTACK) == SUCCESSFUL_BLOCK)
		owner.balloon_alert(owner, "Failed!")
		return TRUE
	victim.Paralyze(grab_time)
	if(!do_after(owner, grab_time, target_atom, IGNORE_USER_LOC_CHANGE|IGNORE_INCAPACITATED|IGNORE_TARGET_LOC_CHANGE, hidden = TRUE))
		owner.balloon_alert(owner, "Escaped!")
		return TRUE
	if(get_dist(owner, target_atom) > grab_distance)
		owner.balloon_alert(owner, "Escaped!")
		return TRUE
	victim.Knockdown(2 SECONDS)
	victim.throw_at(
		target = get_step_towards(owner, victim),
		range  = 8,
		speed = 2,
		thrower = owner,
		diagonals_first = TRUE,
		gentle = FALSE,
	)
	// callback = CALLBACK(src, PROC_REF(tentacle_grab), ling, victim),
	StartCooldown()
	return TRUE


#undef BB_N4_LERAPER_TONGUE_GRAB
