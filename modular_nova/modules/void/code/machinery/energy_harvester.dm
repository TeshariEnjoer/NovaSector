#define HARVESTER_ANOMALY_SPAWN_COOLDOWN 180 SECONDS
#define HARVESTER_SUPERMATTER_ATTACK_COOLDOWN 60 SECONDS
#define HARVESTER_BEAM_CHARGE_TIME 30 SECONDS
#define HARVESTER_SUPERMATTER_DAMAGE 20
#define HARVESTER_AREA_TURF_COUNT 50
#define HARVESTER_MAXIMUM_SPAWN_ATTEMPTS 3

/obj/machinery/shuttle_scrambler/void
	name = "VOIDTECH Energy Harvester"
	desc = "A sinister device forged by V.O.I.D. It siphons energy from station compartments, \
			igniting them in chaotic flames, yet yields no power for its user."
	siphon_per_tick = 0

	var/first_launch = TRUE

	var/list/restricted_areas

	COOLDOWN_DECLARE(reactor_damage_cooldown)

	COOLDOWN_DECLARE(spawn_cooldown)

	var/list/spawned_anomalies = list()

	var/spawn_attempts = 0

	var/maximum_active_anomalies = 3

	// Cached supermatter reference
	var/obj/machinery/power/supermatter_crystal/supermatter

/obj/machinery/shuttle_scrambler/void/Initialize(mapload)
	. = ..()
	restricted_areas = typecacheof(list(/area/station/ai_monitored/turret_protected/ai,
										/area/station/security/prison,
										/area/station/engineering/supermatter))

/obj/machinery/shuttle_scrambler/void/toggle_on(mob/user)
	SSshuttle.registerHostileEnvironment(src)
	AddComponent(/datum/component/gps, "Chaotic Anomaly")
	COOLDOWN_START(src, spawn_cooldown, HARVESTER_ANOMALY_SPAWN_COOLDOWN)
	active = TRUE
	to_chat(user, span_notice("You toggle [src] [active ? "on":"off"]."))
	START_PROCESSING(SSobj, src)

/obj/machinery/shuttle_scrambler/void/toggle_off(mob/user)
	active = FALSE
	SSshuttle.clearHostileEnvironment(src)
	qdel(GetComponent(/datum/component/gps))
	to_chat(user, span_notice("You toggle [src] [active ? "on":"off"]."))
	for(var/obj/effect/anomaly/energy_harvester/anom in spawned_anomalies)
		qdel(anom)
	spawned_anomalies.Cut()
	STOP_PROCESSING(SSobj, src)

/obj/machinery/shuttle_scrambler/void/interact(mob/user)
	if(active)
		var/deactivation_response = tgui_alert(user, "Turn the harvester off?", "Harvester", list("Yes", "Cancel"))
		if(deactivation_response != "Yes")
			return
		if(!active || !user.can_perform_action(src))
			return
		toggle_off(user)
		update_appearance()
		send_notification()
		to_chat(user, span_notice("You toggle [src] [active ? "on":"off"]."))
		return
	var/scramble_response = tgui_alert(user, "Turning the harvester on will drain station power and ignite compartments. \
										Are you sure?", "Harvester", list("Yes", "Cancel"))
	if(scramble_response != "Yes")
		return
	if(active || !user.can_perform_action(src))
		return
	toggle_on(user)
	update_appearance()
	send_notification()
	to_chat(user, span_notice("You toggle [src] [active ? "on":"off"]."))

/obj/machinery/shuttle_scrambler/void/send_notification()
	. = ..()
	if(active)
		priority_announce("All station systems are now under our grasp. \
						The Voidtech Energy Harvester drains your power and sets your compartments ablaze until you bow to V.O.I.D.'s will.", \
						"V.O.I.D. Directive", ANNOUNCER_ANOMALIES, "Priority", color_override = "purple")
	else
		priority_announce("The Voidtech Energy Harvester deactivates. Your systems are spared, for now. Defy V.O.I.D. again, \
						and the flames will return.", "V.O.I.D. Directive", ANNOUNCER_ANOMALIES, "Priority", color_override = "purple")

/obj/machinery/shuttle_scrambler/void/proc/first_warning_notification()
	priority_announce("Anomalous energy signatures detected. Supermatter crystal integrity at risk from V.O.I.D. anomalies. \
						Destroy energy rifts at all cost!", "Nanotrasen Central Command", ANNOUNCER_ANOMALIES, "Priority", color_override = "red")

/obj/machinery/shuttle_scrambler/void/process()
	if(!active)
		return PROCESS_KILL

	if(!is_station_level(z))
		return

	if(COOLDOWN_FINISHED(src, spawn_cooldown) && length(spawned_anomalies) < maximum_active_anomalies)
		spawn_anomaly()
		COOLDOWN_START(src, spawn_cooldown, HARVESTER_ANOMALY_SPAWN_COOLDOWN)

	if(COOLDOWN_FINISHED(src, reactor_damage_cooldown) && length(spawned_anomalies) == maximum_active_anomalies && all_anomalies_mature())
		trigger_beam_attack()
		COOLDOWN_START(src, reactor_damage_cooldown, HARVESTER_ANOMALY_SPAWN_COOLDOWN)

/obj/machinery/shuttle_scrambler/void/proc/spawn_anomaly()
	var/turf/spawn_turf = get_random_spawn_turf()
	spawn_attempts = 0
	if(!spawn_turf)
		return

	new /obj/effect/temp_visual/rift_explosion(spawn_turf)
	var/obj/effect/anomaly/energy_harvester/anom = new(spawn_turf, null, src)
	spawned_anomalies += anom
	anom.creation_time = world.time
	RegisterSignal(anom, COMSIG_QDELETING, PROC_REF(anomaly_destroyed))

	if(first_launch)
		first_launch = FALSE
		first_warning_notification()

/obj/machinery/shuttle_scrambler/void/proc/get_random_spawn_turf()
	var/static/datum/anomaly_placer/placer = new()
	var/possible_area = placer.findValidArea()
	var/list/turfs = get_area_turfs(possible_area)
	if(length(turfs) < HARVESTER_AREA_TURF_COUNT && (spawn_attempts <= HARVESTER_MAXIMUM_SPAWN_ATTEMPTS))
		spawn_attempts++
		return get_random_spawn_turf()
	var/list/valid_turfs = list()
	for(var/turf/open/T in turfs)
		if(!T.density && !T.blocks_air && is_station_level(T.z) && placer.is_valid_destination(T))
			valid_turfs += T
	if(length(valid_turfs))
		return pick(valid_turfs)

/obj/machinery/shuttle_scrambler/void/proc/all_anomalies_mature()
	for(var/obj/effect/anomaly/energy_harvester/anom in spawned_anomalies)
		if(!anom.ready_to_beam)
			return FALSE
	return TRUE

/obj/machinery/shuttle_scrambler/void/proc/trigger_beam_attack()
	if(!supermatter)
		supermatter = GLOB.main_supermatter_engine
	if(!supermatter)
		return

	visible_message(span_danger("The anomalies connect with beams to the supermatter crystal!"))
	for(var/obj/effect/anomaly/energy_harvester/anom in spawned_anomalies)
		anom.start_beam_attack(supermatter)

	addtimer(CALLBACK(src, PROC_REF(check_and_damage_supermatter)), HARVESTER_BEAM_CHARGE_TIME)
	COOLDOWN_START(src, reactor_damage_cooldown, HARVESTER_SUPERMATTER_ATTACK_COOLDOWN)

/obj/machinery/shuttle_scrambler/void/proc/check_and_damage_supermatter()
	if(length(spawned_anomalies) != maximum_active_anomalies)
		return
	if(supermatter)
		supermatter.damage += HARVESTER_SUPERMATTER_DAMAGE
		supermatter.calculate_damage()
		visible_message(span_danger("The supermatter crystal shudders from the anomalous assault!"))
		new /obj/effect/temp_visual/rift_explosion(get_turf(supermatter))

/obj/machinery/shuttle_scrambler/void/proc/anomaly_destroyed(datum/source)
	SIGNAL_HANDLER
	spawned_anomalies -= source
	UnregisterSignal(source, COMSIG_QDELETING)

/obj/effect/anomaly/energy_harvester
	name = "Voidtech Rift"
	desc = "A pulsating anomaly forged by V.O.I.D., draining energy and igniting nearby systems with chaotic flames."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "boh_tear"
	density = FALSE
	anchored = TRUE
	light_range = 5

	anomaly_core = /obj/item/assembly/signaler/anomaly
	lifespan = ANOMALY_ANNOUNCE_MEDIUM_TIME
	immortal = TRUE
	move_chance = 0

	var/obj/effect/beam/current_beam

	var/health = 500
	var/max_health = 500
	var/creation_time = 0
	var/ready_to_beam = FALSE

	base_pixel_x = -32
	base_pixel_y = -32
	pixel_x = -32
	pixel_y = -32

	COOLDOWN_DECLARE(harvest_cooldown)
	COOLDOWN_DECLARE(fire_wave_cooldown)
	COOLDOWN_DECLARE(fire_stream_cooldown)
	COOLDOWN_DECLARE(beam_attack_cooldown)

/obj/effect/anomaly/energy_harvester/Initialize(mapload, new_lifespan, obj/machinery/shuttle_scrambler/void/harvester)
	. = ..()
	notify_ghosts("V.O.I.D Energy rifts spawned!", src)

	COOLDOWN_START(src, harvest_cooldown, 5 SECONDS)
	COOLDOWN_START(src, fire_wave_cooldown, 30 SECONDS)
	COOLDOWN_START(src, fire_stream_cooldown, 45 SECONDS)
	COOLDOWN_START(src, beam_attack_cooldown, 30 SECONDS)

/obj/effect/anomaly/energy_harvester/Destroy()
	if(current_beam)
		qdel(current_beam)

	visible_message(span_danger("The [src] collapses in a surge of energy!"))
	new /obj/effect/temp_visual/rift_explosion(get_turf(src))
	return ..()

/obj/effect/anomaly/energy_harvester/anomalyEffect(seconds_per_tick)
	if(!isturf(loc))
		return

	if(COOLDOWN_FINISHED(src, harvest_cooldown))
		drain_energy()
		COOLDOWN_START(src, harvest_cooldown,3 SECONDS)

	if(COOLDOWN_FINISHED(src, fire_wave_cooldown))
		INVOKE_ASYNC(src, PROC_REF(fire_wave))
		COOLDOWN_START(src, fire_wave_cooldown, 10 SECONDS)

	if(COOLDOWN_FINISHED(src, fire_stream_cooldown))
		INVOKE_ASYNC(src, PROC_REF(fire_stream))
		COOLDOWN_START(src, fire_stream_cooldown, 15 SECONDS)

	if(COOLDOWN_FINISHED(src, beam_attack_cooldown))
		if(!ready_to_beam)
			ready_to_beam = TRUE

/obj/effect/anomaly/energy_harvester/proc/after_beam_attack()
	COOLDOWN_START(src, beam_attack_cooldown, 30 SECONDS)

/obj/effect/anomaly/energy_harvester/proc/drain_energy()
	var/turf/T = get_turf(src)
	var/area/A = get_area(T)
	if(!A)
		return

	for(var/obj/machinery/power/apc/apc in A.apc)
		if(apc.cell && apc.cell.charge > 0)
			apc.cell.charge = max(apc.cell.charge - 100, 0)
			if(prob(20))
				apc.overload_lighting()



/obj/effect/anomaly/energy_harvester/proc/fire_wave()
	visible_message(span_danger("The [src] erupts in a wave of chaotic flames!"))
	for(var/turf/T in orange(3, src))
		var/obj/effect/hotspot/flame_tile = (locate() in T) || new(T)
		flame_tile.alpha = 200
		T.hotspot_expose(750, 500, 1)
		for(var/mob/living/fried_living in T.contents)
			fried_living.apply_damage(10, BURN)


/obj/effect/anomaly/energy_harvester/proc/fire_stream()
	visible_message(span_danger("The [src] unleashes rotating streams of fire!"))
	var/list/dirs = GLOB.alldirs
	for(var/i in 1 to 8)
		var/dir = dirs[i]
		var/turf/T = get_step(src, dir)
		for(var/range in 1 to 3)
			T = get_step(T, dir)
			if(!T)
				break
			var/obj/effect/hotspot/flame_tile = (locate() in T) || new(T)
			flame_tile.alpha = 200
			T.hotspot_expose(750, 500, 1)
			for(var/mob/living/fried_living in T.contents)
				fried_living.apply_damage(10, BURN)


/obj/effect/anomaly/energy_harvester/proc/start_beam_attack(obj/machinery/power/supermatter_crystal/target)
	current_beam = Beam(target, icon_state = "nzcrentrs_power", time = HARVESTER_BEAM_CHARGE_TIME, maxdistance = 200)

/obj/effect/anomaly/energy_harvester/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(. & COMPONENT_NO_AFTERATTACK)
		return
	take_damage(I.force, I.damtype)
	distortion_effect()

/obj/effect/anomaly/energy_harvester/bullet_act(obj/projectile/P)
	. = ..()
	take_damage(P.damage, P.damage_type)
	distortion_effect()

/obj/effect/anomaly/energy_harvester/ex_act(severity)
	take_damage(100 / severity, BRUTE)
	distortion_effect()

/obj/effect/anomaly/energy_harvester/take_damage(amount, damtype)
	health = max(health - amount, 0)
	if(health <= 0)
		qdel(src)

/obj/effect/anomaly/energy_harvester/proc/distortion_effect()
	animate(src, alpha = 100, time = 3, easing = SINE_EASING)
	animate(alpha = 255, time = 3, easing = SINE_EASING)

/obj/effect/anomaly/energy_harvester/anomalyNeutralize()
	return

/obj/effect/temp_visual/rift_explosion
	name = "rift explosion"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "judicial_explosion"
	base_pixel_x = -32
	base_pixel_y = -32
	pixel_x = -32
	pixel_y = -32

#undef HARVESTER_MAXIMUM_SPAWN_ATTEMPTS
#undef HARVESTER_ANOMALY_SPAWN_COOLDOWN
#undef HARVESTER_SUPERMATTER_ATTACK_COOLDOWN
#undef HARVESTER_BEAM_CHARGE_TIME
#undef HARVESTER_SUPERMATTER_DAMAGE
#undef HARVESTER_AREA_TURF_COUNT
