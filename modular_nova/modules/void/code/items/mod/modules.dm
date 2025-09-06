/obj/item/mod/module/void
	icon = 'modular_nova/modules/void/icons/items/mod_modules.dmi'
	overlay_icon_file = 'modular_nova/modules/void/icons/clothing/mod/mod_module.dmi'

/obj/item/mod/module/void/energy_shield
	name = "VOIDTECH energy shield module"
	desc = "A formidable shield generator forged by V.O.I.D., its sleek frame radiates a menacing purple-black aura. \
					Crafted from outlawed Voidtech alloys, this module channels starship-grade deflector energy to block nearly any assault, \
					its surface shimmering with an eerie, otherworldly light. The shield's unstable core demands \
					brief recharges between activations, a grim testament to the fleeting mortality of its wielder. \
					A faint, ominous hum resonates from within, heralding V.O.I.D.'s unyielding dominance."
	icon_state = "energy_shield"
	complexity = 0
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	use_energy_cost = DEFAULT_CHARGE_DRAIN * 2
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/energy_shield,
								/obj/item/mod/module/void/energy_shield)
	required_slots = list(ITEM_SLOT_BACK)

	var/static/list/shield_layers = list(
		/obj/effect/overlay/void_shield
	)

	var/shield_health = 150

	// Maximum damage that shield can tank at hit
	var/damage_threshold = 100

	var/recharge_time = 10 SECONDS

	COOLDOWN_DECLARE(recharge_cooldown)


/obj/item/mod/module/void/energy_shield/on_part_activation()
	mod.wearer.AddComponent(\
		/datum/component/regenerative_shield/void, \
		shield_maxhealth = shield_health, \
		damage_threshold = damage_threshold, \
		regeneration_time = recharge_time, \
		affect_emp = TRUE, \
		)
	RegisterSignal(mod.wearer, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(shield_reaction))
	RegisterSignal(mod.wearer, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examine_more))


/obj/item/mod/module/void/energy_shield/on_part_deactivation(deleting = FALSE)
	var/datum/component/regenerative_shield/shield = mod.wearer.GetComponent(/datum/component/regenerative_shield)
	qdel(shield)
	UnregisterSignal(mod.wearer, COMSIG_LIVING_CHECK_BLOCK)
	UnregisterSignal(mod.wearer, COMSIG_ATOM_EXAMINE_MORE)

/obj/item/mod/module/void/energy_shield/proc/shield_reaction(mob/living/carbon/human/owner,
	atom/movable/hitby,
	damage = 0,
	attack_text = "the attack",
	attack_type = MELEE_ATTACK,
	armour_penetration = 0,
	damage_type = BRUTE
)
	SIGNAL_HANDLER

	if(mod.hit_reaction(owner, hitby, attack_text, 0, damage, attack_type) && attack_type != MELEE_ATTACK)
		drain_power(use_energy_cost)
		return SUCCESSFUL_BLOCK
	return NONE

/obj/item/mod/module/void/energy_shield/proc/on_examine_more(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += list(span_boldnotice("Its purple-black shimmer falters in close combat, \
										offering little defense against melee strikes."))

/obj/item/mod/module/void/energy_shield/emp_act(severity)
	. = ..()
	var/datum/component/regenerative_shield/shield = mod.wearer.GetComponent(/datum/component/regenerative_shield)
	shield.disable_shield()

/obj/effect/overlay/void_shield
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-grey"
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/overlay/void_shield_recharge
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-flash"
	layer = ABOVE_ALL_MOB_LAYER


/datum/component/regenerative_shield/void
	// Current health of shield
	var/shield_health = 0
	// Maximum health of shield
	var/shield_maxhealth = 150
	// Current status of shield
	var/enabled = FALSE
	// Non hit time for shield begings to regenerate
	var/evade_time = 5 SECONDS
	// Is shield reneneration right now
	var/recharging = FALSE
	// Is emp affected to shield
	var/affect_emp = TRUE
	// Damage that emp deals to shield
	var/emp_damage = 50
	// Is shield protect only from ranged attacks
	var/ranged_only = TRUE


	var/recharge_rate = 3

	COOLDOWN_DECLARE(shield_reacharge_cooldown)

	var/obj/effect/overlay/current_overlay

	var/obj/effect/overlay/shield_overlay

	var/obj/effect/overlay/recharge_overlay


/datum/component/regenerative_shield/void/Initialize(shield_maxhealth, \
damage_threshold = 150, \
evade_time = 5 SECONDS, \
regeneration_time = 15 SECONDS, \
affect_emp = TRUE, \
emp_damage = 50, \
ranged_only = TRUE, \
shield_overlay, \
recharge_overlay)

	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	src.shield_maxhealth = shield_maxhealth
	src.damage_threshold = damage_threshold
	src.regeneration_time = regeneration_time
	src.evade_time = evade_time
	src.affect_emp = affect_emp
	src.emp_damage = emp_damage
	src.ranged_only = ranged_only
	src.shield_overlay = shield_overlay
	src.recharge_overlay = recharge_overlay

	var/atom/movable/living_parent = parent
	if(!shield_overlay)
		return

	src.shield_overlay.alpha = 0
	living_parent.vis_contents += shield_overlay
	src.recharge_overlay.alpha = 0
	living_parent.vis_contents += recharge_overlay

	enabled = FALSE

/datum/component/regenerative_shield/void/RegisterWithParent()
	. = ..()
	if(affect_emp)
		RegisterSignal(parent, COMSIG_ATOM_EMP_ACT, PROC_REF(block_attack))

	START_PROCESSING(SSprocessing, src)

/datum/component/regenerative_shield/void/UnregisterFromParent()
	. = ..()
	if(affect_emp)
		UnregisterSignal(parent, COMSIG_ATOM_EMP_ACT)

	STOP_PROCESSING(SSprocessing, src)


/datum/component/regenerative_shield/void/proc/on_emp_act(severity)
	SIGNAL_HANDLER
	handle_shield_damage(emp_damage * severity)


/datum/component/regenerative_shield/void/proc/handle_shield_damage(damage)
	if(damage <= 0)
		return TRUE

	if(recharging)
		var/mob/living/living_parent = parent
		living_parent.balloon_alert("Recharg interupted!")
		set_shield_chraging(FALSE)

	shield_health = max(0, shield_health - damage)
	if(shield_health == 0 || damage >= damage_threshold)
		break_shield()
		return FALSE

	intro_charge_cooldown(evade_time)
	return TRUE

/datum/component/regenerative_shield/void/proc/intro_charge_cooldown(time)
	COOLDOWN_INCREMENT(src, shield_reacharge_cooldown, time)

/datum/component/regenerative_shield/void/block_attack(
	mob/living/source,
	atom/hitby,
	damage,
	attack_text,
	attack_type,
	armour_penetration,
	damage_type,
	attack_flag,
)

	if(!enabled)
		return NONE

	if(attack_type == MELEE_ATTACK && ranged_only)
		return NONE

	if(!handle_shield_damage(damage))
		return TRUE

	playsound(get_turf(parent), 'sound/items/weapons/tap.ogg', 20)
	new /obj/effect/temp_visual/guardian/phase/out(get_turf(parent))
	return SUCCESSFUL_BLOCK


/datum/component/regenerative_shield/void/process(seconds_per_tick)
	if(shield_health >= shield_maxhealth && recharging)
		set_shield_chraging(FALSE)
		recharging = FALSE
		return

	if(!COOLDOWN_FINISHED(src, shield_reacharge_cooldown))
		return
	var/mob/living/living_parent = parent
	living_parent.balloon_alert("Recharging!")
	if(!recharging)
		set_shield_chraging(TRUE)
	shield_health = min(shield_health + max(0, recharge_rate * seconds_per_tick), shield_maxhealth)

	if(!enabled)
		enabled = TRUE


/datum/component/regenerative_shield/void/proc/break_shield()
	brake_shield_effect()


/datum/component/regenerative_shield/void/proc/set_shield_chraging(state)
	if(state == recharging)
		return
	recharging = state
	if(recharging)
		shield_overlay.alpha = 0
		recharge_overlay.alpha = 255
		current_overlay = recharge_overlay
	else
		recharge_overlay.alpha = 0
		shield_overlay.alpha = 255
		current_overlay = shield_overlay
	update_shield_visual()


/datum/component/regenerative_shield/void/proc/update_shield_visual()
	var/status = shield_health / shield_maxhealth
	if(status >= 0.7)
		set_shield_color(COLOR_BLUE)
	else if(status >= 0.3)
		set_shield_color(COLOR_YELLOW)
	else if(status >= 0.01)
		set_shield_color(COLOR_RED)
	else
		set_shield_color(COLOR_WHITE)


/datum/component/regenerative_shield/void/proc/brake_shield_effect()


/datum/component/regenerative_shield/void/proc/set_shield_color(color)
	current_overlay?.color = color


/obj/item/mod/module/void/cloak
	name = "VOIDTECH Shadowveil Cloak"
	desc = "A sinister modular cloak crafted by V.O.I.D., its sleek, jet-black fabric ripples with a haunting purple-black sheen, \
			woven from outlawed Voidtech fibers. The Shadowveil drapes over the wearer, billowing with an eerie, almost sentient presence, \
			nhancing their menace while offering subtle protection against detection. Its surface pulses faintly, \
			as if alive with the dark essence of V.O.I.D.'s forbidden technology. A small, glowing tag whispers: \
			'Property of V.O.I.D. Disturb at your peril.'"
	icon_state = "cloak_traitor"
	complexity = 0
	removable = FALSE
	incompatible_modules = list(/obj/item/mod/module/void/cloak)
	required_slots = list(ITEM_SLOT_NECK)
