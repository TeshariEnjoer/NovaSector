/obj/item/mod/construction/plating/void
	theme = /datum/mod_theme/void_combat


/obj/item/mod/control/pre_equipped/void
	applied_cell = /obj/item/stock_parts/power_store/cell/hyper
	theme = /datum/mod_theme/void_combat



/datum/mod_theme/void_combat
	name = "voidcombat"
	desc = "A menacing modular combat suit forged by V.O.I.D., cloaked in dread and lethal precision."
	extended_desc = "An advanced combat exosuit shrouded in a haunting purple-black hue, crafted by V.O.I.D. \
					for their merciless enforcers. Its sleek plating, forged from Voidtech-enhanced plasteel and \
					reinforced with N-4-infused ceramics, offers unmatched protection. The undersuit, \
					woven from a durathread and kevlar hybrid laced with volatile N-4 filaments, shields vulnerable \
					areas while pulsing with an eerie glow. A flowing black cloak drapes over the suit, \
					billowing with an ominous presence. Integrated with an outlawed Voidtech ablative shield module, \
					it deflects energy-based weaponry with ruthless efficiency. \
					A faintly glowing tag reads: 'Property of V.O.I.D. Unauthorized use will trigger N-4 contagion protocols. All rights terminated.'"
	default_skin = "voidcombat"
	armor_type = /datum/armor/mod_theme_void_combat
	atom_flags = PREVENT_CONTENTS_EXPLOSION_1
	complexity_max = DEFAULT_MAX_COMPLEXITY - 5
	max_heat_protection_temperature = FIRE_SUIT_MAX_TEMP_PROTECT
	siemens_coefficient = 0
	slowdown_deployed = 0
	ui_theme = "syndicate"
	resistance_flags = FIRE_PROOF | LAVA_PROOF | ACID_PROOF
	inbuilt_modules = list(
		/obj/item/mod/module/welding/syndicate,
		/obj/item/mod/module/hearing_protection,
		/obj/item/mod/module/void/energy_shield,
		/obj/item/mod/module/void/cloak
	)
	allowed_suit_storage = list(
		/obj/item/restraints/handcuffs,
		/obj/item/assembly/flash,
		/obj/item/melee/baton,
		/obj/item/melee/energy/sword,
		/obj/item/shield/energy,
	)
	variants = list(
		"voidcombat" = list(
			MOD_ICON_OVERRIDE = 'modular_nova/modules/void/icons/items/mod_clothing.dmi',
			MOD_WORN_ICON_OVERRIDE = 'modular_nova/modules/void/icons/clothing/mod/mod_clothing.dmi',
			/obj/item/clothing/head/mod = list(
				UNSEALED_LAYER = NECK_LAYER,
				UNSEALED_CLOTHING = SNUG_FIT,
				SEALED_CLOTHING = THICKMATERIAL|STOPSPRESSUREDAMAGE|HEADINTERNALS,
				UNSEALED_INVISIBILITY = HIDEFACIALHAIR,
				SEALED_INVISIBILITY = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT,
				SEALED_COVER = HEADCOVERSMOUTH|HEADCOVERSEYES|PEPPERPROOF,
				UNSEALED_MESSAGE = HELMET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = HELMET_SEAL_MESSAGE,
			),
			/obj/item/clothing/suit/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				SEALED_INVISIBILITY = HIDEJUMPSUIT,
				UNSEALED_MESSAGE = CHESTPLATE_UNSEAL_MESSAGE,
				SEALED_MESSAGE = CHESTPLATE_SEAL_MESSAGE,
			),
			/obj/item/clothing/gloves/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = GAUNTLET_UNSEAL_MESSAGE,
				SEALED_MESSAGE = GAUNTLET_SEAL_MESSAGE,
			),
			/obj/item/clothing/shoes/mod = list(
				UNSEALED_CLOTHING = THICKMATERIAL,
				SEALED_CLOTHING = STOPSPRESSUREDAMAGE,
				CAN_OVERSLOT = TRUE,
				UNSEALED_MESSAGE = BOOT_UNSEAL_MESSAGE,
				SEALED_MESSAGE = BOOT_SEAL_MESSAGE,
			),
		)
	)

/datum/armor/mod_theme_void_combat
	melee = 90
	bullet = 80
	laser = 80
	energy = 80
	bomb = 80
	bio = 100
	fire = 100
	acid = 80
	wound = 40

