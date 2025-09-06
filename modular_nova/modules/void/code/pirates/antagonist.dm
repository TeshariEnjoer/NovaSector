/datum/antagonist/void_raiders
	name = "\improper ???"
	pref_flag = ROLE_SPACE_PIRATE
	roundend_category = "void raiders"
	antagpanel_category = "V.O.I.D"
	show_in_antagpanel = FALSE
	show_to_ghosts = TRUE
	suicide_cry = "There no mercy..."

	var/datum/team/void_raiders/squad






/datum/team/void_raiders
	name = "\improper V.O.I.D Squad"

/datum/team/void_raiders/proc/forge_objectives()
	add_objective(new /datum/objective/void_violence)
	add_objective(new /datum/objective/void_omnipotence)
	add_objective(new /datum/objective/void_impromptu)
	add_objective(new /datum/objective/void_destruction)


/datum/objective/void_violence
	name = "violence"
	explanation_text = "Sow chaos and fear across the station. Eliminate or subjugate all who resist V.O.I.D. dominance through unrelenting force."
	martyr_compatible = TRUE

/datum/objective/void_omnipotence
	name = "omnipotence"
	explanation_text = "Prove V.O.I.D.'s supremacy by seizing control of critical resources, technology, showcasing our unmatched voidtech superiority."
	martyr_compatible = TRUE

/datum/objective/void_impromptu
	name = "impromptu"
	explanation_text = "Launch sudden, unpredictable assaults on the station's systems or crew, spreading N-4 infections or sabotage to sow panic while ensuring some survivors spread tales of V.O.I.D.'s terror."
	martyr_compatible = TRUE

/datum/objective/void_destruction
	name = "destruction"
	explanation_text = "Devastate the station's critical infrastructure or defenses that oppose V.O.I.D.'s will, leaving remnants of the crew alive to witness and fear our inevitable dominance."
	martyr_compatible = TRUE
