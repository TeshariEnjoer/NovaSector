/datum/outfit/pirate/void
	implants = list(/obj/item/implant/explosive,
					/obj/item/implant/weapons_auth)

/datum/outfit/pirate/void/post_equip(mob/living/carbon/human/equipped)
	. = ..()
	equipped.faction -= "pirate"
	equipped.faction |= FACTION_VOID


	var/list/to_insert = list(
		new /obj/item/organ/heart/cybernetic/voidtech(),
		new /obj/item/organ/lungs/cybernetic/voidtech(),
		new /obj/item/organ/liver/cybernetic/voidtech(),
		new /obj/item/organ/eyes/robotic/thermals/voidtech(),
		new /obj/item/organ/stomach/cybernetic/voidtech()
	)
	for(var/obj/item/organ/aug in to_insert)
		aug.Insert(equipped, TRUE, DELETE_IF_REPLACED)

