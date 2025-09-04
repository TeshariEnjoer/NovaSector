/mob/living/basic/n4_mutant
	name = "???"
	icon = 'modular_nova/modules/void/icons/mob/mutants96.dmi'
	health = 500
	maxHealth = 750
	combat_mode = TRUE
	max_stamina = BASIC_MOB_NO_STAMCRIT
	status_flags = CANSTUN
	mob_size = MOB_SIZE_HUGE
	mob_biotypes = MOB_ORGANIC|MOB_SPECIAL
	faction = list(FACTION_VOID)
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	damage_coeff = list(BRUTE = 0.8, BURN = 0.8, TOX = 0, STAMINA = 0.3, OXY = 0)
	obj_damage = 100
	armour_penetration = 40
	wound_bonus = WOUND_DISMEMBER_OUTRIGHT_THRESH
	melee_attack_cooldown = 4 SECONDS
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	pixel_x = -32
	pixel_y = -32
	base_pixel_x = -32
	base_pixel_y = -32



/mob/living/basic/n4_mutant/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/relay_attackers)





