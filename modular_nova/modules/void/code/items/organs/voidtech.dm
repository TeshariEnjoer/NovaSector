#define VOIDTECH_HEART_HEAL_COOLDOWN 5 * 10
#define VOIDTECH_HEART_HEAL_TRESHOLD 75

// A voidtech organs

/obj/item/organ/heart/cybernetic/voidtech
	name = "Voidtech Duskheart"
	desc = "A sinister Voidtech construct pulsing with unnatural energy, designed to supplant an organic heart. Its dark machinery hums with relentless efficiency, infused with traces of N-4 viral essence."
	icon = 'modular_nova/modules/void/icons/items/organs.dmi'
	icon_state = "heart-vt-on"
	base_icon_state = "heart-vt"
	organ_flags = ORGAN_ROBOTIC
	maxHealth = STANDARD_ORGAN_THRESHOLD * 2
	failing_desc = "emits a faint, eerie whine, its mechanisms faltering."
	beat_noise = "a low, ominous thrum laced with static"
	stabilization_available = TRUE
	stabilization_duration = 40 SECONDS
	bleed_prevention = TRUE
	toxification_probability = 0
	emp_vulnerability = 10

	COOLDOWN_DECLARE(heal_cooldown)

/obj/item/organ/heart/cybernetic/voidtech/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(owner.health < VOIDTECH_HEART_HEAL_TRESHOLD && COOLDOWN_FINISHED(src, heal_cooldown))
		COOLDOWN_START(src, heal_cooldown, VOIDTECH_HEART_HEAL_COOLDOWN)
		owner.heal_overall_damage(brute = 5, burn = 5, required_bodytype = BODYTYPE_ORGANIC)
		if(owner.reagents.get_reagent_amount(/datum/reagent/medicine/ephedrine) < 20)
			owner.reagents.add_reagent(/datum/reagent/medicine/ephedrine, 10)

		if(owner.stat == HARD_CRIT && !owner.has_reagent(/datum/reagent/medicine/atropine, 5))
			owner.reagents.add_reagent(/datum/reagent/medicine/atropine, 1 * seconds_per_tick)


/obj/item/organ/lungs/cybernetic/voidtech
	name = "Voidtech Shadowlungs"
	desc = "A pair of sinister Voidtech constructs that replace organic lungs, pulsing with dark, N-4-infused mechanisms. \
			They hum with an eerie efficiency, sustaining life through unnatural means."
	failing_desc = "emits a faint, rasping hiss, its dark machinery stuttering."
	icon = 'modular_nova/modules/void/icons/items/organs.dmi'
	icon_state = "lungs-vt"
	breath_noise = "a low, unsettling hum interspersed with sharp clicks"
	organ_flags = ORGAN_ROBOTIC
	maxHealth = STANDARD_ORGAN_THRESHOLD * 2
	emp_vulnerability = 10

	safe_plasma_max = 30
	safe_co2_max = 30
	safe_oxygen_min = 7

	cold_level_1_threshold = 250
	cold_level_2_threshold = 170
	cold_level_3_threshold = 120


/obj/item/organ/eyes/robotic/thermals/voidtech
	name = "Voidtech Gloomvisors"
	desc = "Sinister Voidtech eye implants that pierce the darkness with thermal vision, \
			their slit apertures glowing with an unnatural crimson hue, \
			they reveal the world in a haunting purple twilight."
	icon = 'modular_nova/modules/void/icons/items/organs.dmi'
	icon_state = "eyes-vt"
	iris_overlay = null
	eye_color_left = "#5c05ce"
	eye_color_right = "#5c05ce"
	color_cutoffs = list(20, 15, 25) // Adjusted for purple-tinted darkness
	sight_flags = SEE_MOBS
	flash_protect = FLASH_PROTECTION_SENSITIVE
	pupils_name = "slit apertures"
	penlight_message = "are Voidtech cybernetics, with vertically slit lenses pulsing faintly"


/obj/item/organ/liver/cybernetic/voidtech
	name = "Voidtech Duskfilter"
	desc = "A foreboding Voidtech organ that mimics a human liver, infused with N-4 viral traces. \
			Its dark machinery processes toxins with ruthless precision, though slightly less effectively than its organic counterpart."
	failing_desc = "emits a low, grinding hum, its sinister mechanisms faltering."
	icon = 'modular_nova/modules/void/icons/items/organs.dmi'
	icon_state = "liver-vt"
	organ_flags = ORGAN_ROBOTIC
	maxHealth = STANDARD_ORGAN_THRESHOLD * 2

	toxTolerance = 30
	emp_vulnerability = 10
	alcohol_tolerance = ALCOHOL_RATE * 0.2
	liver_resistance = 1.5 * LIVER_DEFAULT_TOX_RESISTANCE


/obj/item/organ/liver/cybernetic/voidtech/on_life(seconds_per_tick, times_fired)
	. = ..()

	if(owner.blood_volume < BLOOD_VOLUME_NORMAL)
		owner.blood_volume += 2 * seconds_per_tick


/obj/item/organ/stomach/cybernetic/voidtech
	name = "Voidtech Grimforge"
	desc = "A menacing Voidtech construct designed to replicate a human stomach, infused with N-4 viral essence. \
			Its dark mechanisms churn with unsettling precision, processing sustenance with cold efficiency."
	failing_desc = "emits a faint, guttural whir, its ominous machinery stalling."
	icon_state = "stomach-vt"
	icon = 'modular_nova/modules/void/icons/items/organs.dmi'
	organ_flags = ORGAN_ROBOTIC
	maxHealth = STANDARD_ORGAN_THRESHOLD * 1.5
	metabolism_efficiency = 0.025
	emp_vulnerability = 10

#undef VOIDTECH_HEART_HEAL_COOLDOWN
#undef VOIDTECH_HEART_HEAL_TRESHOLD



