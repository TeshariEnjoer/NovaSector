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

	var/maximum_hits = 20

	var/shield_maxhealth = 100

	var/recharge_time = 10 SECONDS

	COOLDOWN_DECLARE(recharge_cooldown)


/obj/item/mod/module/void/energy_shield/on_part_activation()
	mod.wearer.AddComponent(\
		/datum/component/regenerative_shield, \
		number_of_hits = maximum_hits, \
		damage_threshold = shield_maxhealth, \
		regeneration_time = recharge_time, \
		shield_overlays = shield_layers)
	RegisterSignal(mod.wearer, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(shield_reaction))


/obj/item/mod/module/void/energy_shield/on_part_deactivation(deleting = FALSE)
	var/datum/component/regenerative_shield/shield = mod.wearer.GetComponent(/datum/component/regenerative_shield)
	qdel(shield)
	UnregisterSignal(mod.wearer, COMSIG_LIVING_CHECK_BLOCK)

/obj/item/mod/module/void/energy_shield/proc/shield_reaction(mob/living/carbon/human/owner,
	atom/movable/hitby,
	damage = 0,
	attack_text = "the attack",
	attack_type = MELEE_ATTACK,
	armour_penetration = 0,
	damage_type = BRUTE
)
	SIGNAL_HANDLER

	if(mod.hit_reaction(owner, hitby, attack_text, 0, damage, attack_type))
		drain_power(use_energy_cost)
		return SUCCESSFUL_BLOCK
	return NONE

/obj/item/mod/module/void/energy_shield/emp_act(severity)
	. = ..()
	var/datum/component/regenerative_shield/shield = mod.wearer.GetComponent(/datum/component/regenerative_shield)
	shield.disable_shield()

/obj/effect/overlay/void_shield
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	vis_flags = VIS_INHERIT_DIR | VIS_INHERIT_PLANE
	icon = 'icons/effects/effects.dmi'
	icon_state = "psychic"
	layer = ABOVE_ALL_MOB_LAYER


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
