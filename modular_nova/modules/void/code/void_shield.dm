/obj/effect/overlay/void_shield
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-grey"
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/overlay/void_shield_recharge
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-flash"
	layer = ABOVE_ALL_MOB_LAYER

/datum/component/void_shield
	var/shield_health = 0
	var/shield_maxhealth = 150
	var/enabled = FALSE
	var/evade_time = 5 SECONDS
	var/recharging = FALSE
	var/affect_emp = TRUE
	var/emp_damage = 50
	var/ranged_only = TRUE
	var/recharge_rate = 4

	///the limit of the damage we can tank
	var/damage_threshold
	///how long before the shield can regenerate
	var/regeneration_time


	COOLDOWN_DECLARE(shield_recharge_cooldown)

	var/obj/effect/overlay/current_overlay

	var/obj/effect/overlay/shield_overlay

	var/obj/effect/overlay/recharge_overlay

	var/mob/living/living_parent

/datum/component/void_shield/Initialize(shield_maxhealth, \
damage_threshold = 150, \
evade_time = 5 SECONDS, \
regeneration_time = 15 SECONDS, \
affect_emp = TRUE, \
emp_damage = 50, \
ranged_only = TRUE, \
obj/effect/overlay/overlay_shield, \
obj/effect/overlay/overlay_charge)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	living_parent = parent
	src.shield_maxhealth = shield_maxhealth
	src.damage_threshold = damage_threshold
	src.regeneration_time = regeneration_time
	src.evade_time = evade_time
	src.affect_emp = affect_emp
	src.emp_damage = emp_damage
	src.ranged_only = ranged_only
	src.shield_overlay = new overlay_shield()
	src.recharge_overlay = new overlay_charge()


	shield_overlay.alpha = 0
	recharge_overlay.alpha = 0
	living_parent.vis_contents += shield_overlay
	living_parent.vis_contents += recharge_overlay

	enabled = FALSE

/datum/component/void_shield/RegisterWithParent()
	. = ..()
	if(affect_emp)
		RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(on_emp_act))
	RegisterSignal(parent, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(block_attack))
	START_PROCESSING(SSprocessing, src)


/datum/component/void_shield/UnregisterFromParent()
	. = ..()
	if(affect_emp)
		UnregisterSignal(parent, COMSIG_ATOM_EMP_ACT)
	UnregisterSignal(parent, COMSIG_LIVING_CHECK_BLOCK)
	living_parent.vis_contents -= shield_overlay
	living_parent.vis_contents -= recharge_overlay
	qdel(shield_overlay)
	qdel(recharge_overlay)
	STOP_PROCESSING(SSprocessing, src)

/datum/component/void_shield/proc/on_emp_act(severity)
	SIGNAL_HANDLER
	handle_shield_damage(emp_damage * severity)

/datum/component/void_shield/proc/handle_shield_damage(damage)
	if(damage <= 0)
		return TRUE
	if(recharging)
		living_parent.balloon_alert(living_parent, "Recharge interrupted!")
		set_shield_charging(FALSE)
	shield_health = max(0, shield_health - damage)
	if(shield_health == 0 || damage >= damage_threshold)
		break_shield()
		return FALSE
	inrto_cooldown(evade_time)
	return TRUE

/datum/component/void_shield/proc/block_attack(
	mob/living/source,
	atom/hitby,
	damage,
	attack_text,
	attack_type,
	armour_penetration,
	damage_type,
	attack_flag
)
	if(!enabled)
		return NONE
	if(attack_type == MELEE_ATTACK && ranged_only)
		return NONE
	if(!handle_shield_damage(damage))
		return NONE
	playsound(get_turf(parent), 'sound/items/weapons/tap.ogg', 20)
	new /obj/effect/temp_visual/guardian/phase/out(get_turf(parent))
	if(current_overlay == shield_overlay)
		damage_shield_effect()
	return SUCCESSFUL_BLOCK



/datum/component/void_shield/proc/inrto_cooldown(time)
	COOLDOWN_INCREMENT(src, shield_recharge_cooldown, time)

/datum/component/void_shield/process(seconds_per_tick)
	if(shield_health >= shield_maxhealth || !COOLDOWN_FINISHED(src, shield_recharge_cooldown))
		return
	if(!recharging)
		living_parent.balloon_alert(living_parent, "Shield recharging!")
		set_shield_charging(TRUE)
	if(!enabled)
		enabled = TRUE

	shield_health = min(shield_health + recharge_rate * seconds_per_tick, shield_maxhealth)
	update_shield_visual()
	if(shield_health >= shield_maxhealth)
		set_shield_charging(FALSE)


/datum/component/void_shield/proc/break_shield()
	enabled = FALSE
	brake_shield_effect()
	inrto_cooldown(regeneration_time)
	new /obj/effect/temp_visual/cosmic_explosion(get_turf(parent))

/datum/component/void_shield/proc/brake_shield_effect()
	if(!current_overlay)
		return
	animate(current_overlay, alpha = 0, time = 3, easing = SINE_EASING)
	current_overlay.filters += filter(type="wave", size=12, offset=0)
	animate(current_overlay.filters[length(current_overlay.filters)], size=0, offset=1, time=3, easing=SINE_EASING)
	addtimer(CALLBACK(src, PROC_REF(clear_filters), current_overlay), 3)

/datum/component/void_shield/proc/damage_shield_effect()
	if(!shield_overlay)
		return
	shield_overlay.clear_filters()
	shield_overlay.filters += filter(type="wave", size=8, offset=0)
	animate(shield_overlay.filters[1], size=0, offset=1, time=3, easing=SINE_EASING)
	animate(shield_overlay, alpha=255, time=1, easing=LINEAR_EASING)
	animate(alpha=50 + (shield_health / shield_maxhealth * 150), time=3, easing=LINEAR_EASING)
	addtimer(CALLBACK(src, PROC_REF(clear_filters), shield_overlay), 3)

/datum/component/void_shield/proc/clear_filters(obj/effect/overlay/target)
	if(target)
		target.filters = null


/datum/component/void_shield/proc/set_shield_charging(state)
	if(recharging == state)
		return
	recharging = state
	current_overlay = recharging ? recharge_overlay : shield_overlay
	animate(shield_overlay, alpha = recharging ? 0 : 200, time = 5, easing = SINE_EASING)
	animate(recharge_overlay, alpha = recharging ? 200 : 0, time = 5, easing = SINE_EASING)
	update_shield_visual()

/datum/component/void_shield/proc/update_shield_visual()
	var/status = shield_health / shield_maxhealth
	var/target_color
	if(status >= 0.7)
		target_color = COLOR_VIOLET
	else if(status >= 0.3)
		target_color = COLOR_YELLOW
	else if(status >= 0.01)
		target_color = COLOR_RED
	else
		target_color = COLOR_WHITE

	if(current_overlay)
		var/target_alpha = 50 + (status * 150)
		animate(current_overlay, color = target_color, time = 7, easing = LINEAR_EASING)
		animate(current_overlay, alpha = target_alpha, time = 3, easing = LINEAR_EASING)
