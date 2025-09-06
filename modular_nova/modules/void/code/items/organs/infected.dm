#define ORGAN_N4_CORRUPTED  (1<<32)

/obj/item/organ/heart/n4
	name = "N-4 Tainted Heart"
	desc = "A grotesque, N-4-corrupted human heart, swollen with pulsating black veins. Its sickly flesh writhes with viral decay, barely sustaining life while threatening to spread the Voidplague's curse."
	icon = 'modular_nova/modules/void/icons/items/organs.dmi'
	icon_state = "heart-n4-on"
	base_icon_state = "heart-n4"
	organ_flags = ORGAN_N4_CORRUPTED
	maxHealth = STANDARD_ORGAN_THRESHOLD*0.2
	beat_noise = "a wretched, irregular thump laced with sickly gurgles. You <b>must not touch this</b> lest it infects you."

	COOLDOWN_DECLARE(damage_cooldown)

/obj/item/organ/heart/n4/on_life(seconds_per_tick, times_fired)
	. = ..()
	if(COOLDOWN_FINISHED(src, damage_cooldown))
		COOLDOWN_START(src, damage_cooldown, 10 SECONDS)
		owner.apply_damage(rand(4, 13), wound_clothing = FALSE)


/obj/item/organ/heart/n4/pickup(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/owner = user

	if(!owner.gloves && !owner.HasDisease(/datum/disease/n4))
		owner.ForceContractDisease(new /datum/disease/n4(), FALSE, TRUE)


/obj/item/organ/liver/n4
	name = "N-4 Blighted Liver"
	desc = "A grotesque, N-4-corrupted human liver, riddled with pulsating black tendrils. \
			Its decayed tissue struggles to filter toxins, exuding a sickly miasma that threatens to spread the Voidplague's curse."
	icon_state = "liver-n4"
	organ_flags = ORGAN_N4_CORRUPTED
	maxHealth = STANDARD_ORGAN_THRESHOLD * 0.1
	alcohol_tolerance = ALCOHOL_RATE * 2
	toxTolerance = 1
	liver_resistance = 0.15 * LIVER_DEFAULT_TOX_RESISTANCE


/obj/item/organ/lungs/n4
	name = "N-4 Withered Lungs"
	desc = "A pair of decaying, N-4-corrupted human lungs, riddled with pulsating black lesions. \
			Their frail tissue wheezes with every breath, exuding a toxic miasma that threatens to spread the Voidplague's curse."
	breath_noise = "a wretched, rattling wheeze laced with sickly gurgles. You <b>must not touch this</b> lest it infects you."
	icon_state = "lungs-n4"
	organ_flags = ORGAN_N4_CORRUPTED
	maxHealth = 0.20 * STANDARD_ORGAN_THRESHOLD


/obj/item/organ/stomach/n4
	name = "N-4 Rotted Stomach"
	desc = "A grotesque, N-4-corrupted human stomach, festering with writhing black tendrils. \
			Its decayed tissue barely processes sustenance, oozing a toxic sludge that carries the Voidplague's curse."
	icon_state = "stomach-n4"
	organ_flags = ORGAN_N4_CORRUPTED
	maxHealth = STANDARD_ORGAN_THRESHOLD * 0.1
	metabolism_efficiency = 0.001

