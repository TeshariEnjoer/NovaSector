/datum/pirate_gang/voids
	name = "???"

	is_heavy_threat = TRUE
	ship_template_id = "voidbattcruiser"
	ship_name_pool = "void_names"

	threat_title = "???"
	threat_content = " \
					Greetings, inferior station. \n \
					We are V.O.I.D. Our reconnaissance drone has confirmed your unauthorized presence within our sovereign domain. \n \
					You are hereby ordered to evacuate our territory immediately or procure residency rights for %PAYOFF credits. \n \
					This is your final warning. Resistance is futile."
	arrival_announcement = " \
					Pathetic crew, tremble before V.O.I.D. \n \
					Our warship has breached your pitiful sector and now looms over your station. n\
					Surrender immediately or be erased from existence. \n \
					No pleas will be heard. No mercy will be granted. \n \
					Your time runs thin."
	possible_answers = list("We submit and will transfer the credits.","We defy your pathetic demands!")

	response_received = " \
					Your credits have been processed, insects. \n \
					V.O.I.D. grants you temporary existence within our domain. \n \
					Do not test our patience further."

	response_rejected = " \
					Foolish defiance! \n \
					V.O.I.D. will crush your insignificant station and harvest your remains for our archives. \n \
					Prepare for annihilation!"

	response_too_late = " \
					Your time has expired, vermin. \n \
					V.O.I.D. does not tolerate delays. \n \
					Our warship will reduce your station to ash."
	response_not_enough = " \
					You dare insult V.O.I.D. with insufficient tribute? \n \
					Your deceit seals your fate. \n \
					Prepare for immediate eradication!"


/obj/effect/mob_spawn/ghost_role/human/void_raider
	name = "??? sleeper"
	prompt_name = "a V.O.I.D Riftbreaker"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "psykerpod"
	mob_species = /datum/species/human
	faction = list(FACTION_RAIDER)
	you_are_text = "You are a V.O.I.D. strike force."
	flavour_text = "The station has defied V.O.I.D.'s ultimatum. Enforce our will by spreading chaos and extracting submission. Violence is preferred, but terror and sabotage are equally effective."
	important_text = "Allowed races: humans, teshari. Obey your Overlord Ascendant. You are not mere pirates—roleplay as the harbingers of V.O.I.D.'s supremacy."
	outfit = /datum/outfit/pirate/void
	restricted_species = list(/datum/species/human, /datum/species/teshari)
	random_appearance = FALSE
	show_flavor = TRUE


/datum/map_template/shuttle/pirate/nri_raider
	prefix = "_maps/shuttles/nova/"
	suffix = "voidbattlecruiser"
	name = "pirate ship (V.O.I.D liquidator)"


/obj/docking_port/mobile/pirate/void
	name = "V.O.I.D. liquidator"
	initial_engine_power = 6
	port_direction = EAST
	preferred_direction = EAST
	callTime = 1 MINUTES
	rechargeTime = 2 MINUTES
	movement_force = list("KNOCKDOWN"=5,"THROW"=10)
	can_move_docking_ports = TRUE
	takeoff_sound = sound('modular_nova/modules/encounters/sounds/engine_ignit_int.ogg')
	landing_sound = sound('modular_nova/modules/encounters/sounds/env_ship_down.ogg')


/area/shuttle/pirate/void
	name = "V.O.I.D Starship"
	forced_ambience = TRUE
	ambient_buzz = 'modular_nova/modules/encounters/sounds/amb_ship_01.ogg'
	ambient_buzz_vol = 15
	ambientsounds = list('modular_nova/modules/encounters/sounds/alarm_radio.ogg',
						'modular_nova/modules/encounters/sounds/alarm_small_09.ogg',
						'modular_nova/modules/encounters/sounds/gear_loop.ogg',
						'modular_nova/modules/encounters/sounds/gear_start.ogg',
						'modular_nova/modules/encounters/sounds/gear_stop.ogg',
						'modular_nova/modules/encounters/sounds/intercom_loop.ogg')


// Real
/obj/structure/steps/no_knockdown
	name = "safe steps"
	desc = "A small set of steps you can use to reach high shelves or climb onto platforms, you don't need to watch your ankles."

/obj/structure/steps/no_knockdown/on_enter()
	return

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/steps/no_knockdown, 0)
