/obj/item/organ/cyberimp/voidtech
	aug_icon = 'modular_nova/modules/void/icons/cyberimp/bodypart_overlay_augmentations.dmi'
	icon = 'modular_nova/modules/void/icons/items/organs.dmi'


/obj/item/organ/cyberimp/voidtech/chest
	name = "voidtech torso implant"
	desc = "Implants for the organs in your torso."
	zone = BODY_ZONE_CHEST


/obj/item/organ/cyberimp/voidtech/chest/death_acidifier
	name = "Voidtech Corpseveil"
	desc = ""
	icon_state = "implant_death_acidifier"



/obj/item/organ/cyberimp/voidtech/chest/death_acidifier/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()





