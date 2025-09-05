/mob/living/basic/n4_mutant
	name = "???"
	icon = 'modular_nova/modules/void/icons/mob/mutants96.dmi'
	health = 750
	maxHealth = 750
	combat_mode = TRUE
	max_stamina = BASIC_MOB_NO_STAMCRIT
	status_flags = CANSTUN
	mob_size = MOB_SIZE_HUGE
	mob_biotypes = MOB_ORGANIC|MOB_SPECIAL
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	layer = LARGE_MOB_LAYER
	can_buckle_to = FALSE
	faction = list(FACTION_VOID, FACTION_HOSTILE) // Be default we freindly with V.O.I.D members
	unsuitable_atmos_damage = 0
	minimum_survivable_temperature = 0
	maximum_survivable_temperature = INFINITY
	damage_coeff = list(BRUTE = 0.8, BURN = 0.8, TOX = 0, STAMINA = 0.3, OXY = 0)
	move_force = MOVE_FORCE_EXTREMELY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	pull_force = MOVE_FORCE_EXTREMELY_STRONG
	obj_damage = 100
	armour_penetration = 50
	wound_bonus = WOUND_DISMEMBER_OUTRIGHT_THRESH
	melee_attack_cooldown = 2 SECONDS
	habitable_atmos = list("min_oxy" = 0, "max_oxy" = 0, "min_plas" = 0, "max_plas" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	mouse_opacity = MOUSE_OPACITY_OPAQUE
	pixel_x = -32
	pixel_y = -32
	base_pixel_x = -32
	base_pixel_y = -32
	ai_controller = /datum/ai_controller/basic_controller/n4_mutant


/mob/living/basic/n4_mutant/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/relay_attackers)





