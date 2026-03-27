class_name WaveData
extends RefCounted

const WORLD_SIZE := Vector2(1280.0, 720.0)
const PLAY_BOUNDS_MARGIN_X := 70.0
const PLAY_BOUNDS_TOP := 250.0
const PLAY_BOUNDS_BOTTOM_MARGIN := 74.0
const FARMHOUSE_POS := Vector2(640.0, 610.0)
const DRILL_SITE_POS := Vector2(640.0, 386.0)
const BASE_TURRET_COST := 8
const FARM_STRUCTURE_ORDER := ["barn", "power_shed", "silo"]
const FARM_STRUCTURE_REPAIR_PRIORITY := ["power_shed", "silo", "barn"]
const FARM_STRUCTURE_DEFS := {
	"barn": {"name":"Barn", "type":"barn", "position":Vector2(236.0, 542.0), "health":8},
	"power_shed": {"name":"Power Shed", "type":"power_shed", "position":Vector2(938.0, 602.0), "health":6},
	"silo": {"name":"Silo", "type":"silo", "position":Vector2(1054.0, 470.0), "health":9},
}
const BARN_SURVIVAL_BONUS := 2
const POWER_SHED_FIRE_PENALTY := 1.30
const SILO_DAMAGE_PENALTY := 1

const WEAPON_NAILGUN := "nailgun"
const WEAPON_SCRAP_BLASTER := "scrap_blaster"
const WEAPON_TRACTOR_CANNON := "tractor_cannon"
const BUILD_COIL_TURRET := "coil_turret"
const BUILD_SHOCK_POST := "shock_post"
const BUILD_BARRICADE := "barricade"
const SCRAP_BLASTER_PELLET_COUNT := 5
const SCRAP_BLASTER_SPREAD := 0.30
const NAILGUN_FALLOFF_START := 150.0
const NAILGUN_FALLOFF_END := 350.0

const TOUCH_PAD_SIZE := Vector2(156.0, 156.0)
const TOUCH_KNOB_SIZE := Vector2(62.0, 62.0)
const TOUCH_PAD_RADIUS := 54.0

const ACT_ONE_WAVES = [
	{
		"title": "Act 1: First Contact",
		"story": "Strange lights sweep over the corn. Eli grabs his barn-built nailgun while Patch circles the porch, waiting for the first landing.",
		"objective": "Hold the north fence against 6 scout saucers.",
		"spawn_count": 6,
		"driller_count": 0,
		"harrier_count": 0,
		"spawn_interval": 1.95,
		"start_delay": 0.80,
		"spawn_mode": "top",
	},
	{
		"title": "Wave 2: Fence Breakers",
		"story": "The first wrecks are still smoking. Patch takes on a real job while a second alien rush lines up over the field, and a few raiders angle straight toward the farm's power shed.",
		"objective": "Stop 8 raiders, including the first driller brute, and keep the power shed online.",
		"spawn_count": 8,
		"driller_count": 1,
		"harrier_count": 0,
		"structure_raids": [{"id":"power_shed", "count":2}],
		"spawn_interval": 1.75,
		"start_delay": 0.75,
		"spawn_mode": "mixed",
	},
	{
		"title": "Wave 3: Drill Team",
		"story": "The invaders stop probing and start drilling. A real rig unfolds in the north field while driller aliens sprint to feed it power.",
		"objective": "Destroy the north-field drill rig and break 10 attackers before it breaches the field.",
		"spawn_count": 10,
		"driller_count": 2,
		"harrier_count": 0,
		"drill_site": true,
		"drill_rate": 2.30,
		"drill_health": 10,
		"spawn_interval": 1.50,
		"start_delay": 0.70,
		"spawn_mode": "sides",
	},
	{
		"title": "Wave 4: North Field Signal",
		"story": "Crop circles are no longer random. The whole north field lines up around a relay mast dropped over something buried deep below the roots while blue harriers start firing from above the rows and scouts slash toward Eli's barn workshop.",
		"objective": "Destroy the signal relay, clear 12 invaders, and keep the barn workshop standing.",
		"spawn_count": 12,
		"driller_count": 2,
		"harrier_count": 2,
		"structure_raids": [{"id":"barn", "count":3}],
		"relay_trigger_spawned": 5,
		"relay_position": Vector2(316.0, 250.0),
		"relay_health": 8,
		"relay_interval": 5.30,
		"relay_boost_multiplier": 1.25,
		"relay_boost_duration": 3.00,
		"relay_drill_boost": 0.0,
		"relay_scrap": 5,
		"spawn_interval": 1.30,
		"start_delay": 0.70,
		"spawn_mode": "top",
	},
	{
		"title": "Wave 5: Harvester Approach",
		"story": "More lights peel off the mothership. A second relay slams down near the silo while shield drones start screening the rush, burrowers cut under the fence, harriers strafe the farmhouse, and raiders split off toward the silo and power shed.",
		"objective": "Smash the new signal relay, crack the shield drones, catch the first burrowers, hold off 14 attackers, and stop the silo and power shed from falling.",
		"spawn_count": 14,
		"driller_count": 3,
		"harrier_count": 3,
		"shield_count": 2,
		"burrower_count": 2,
		"structure_raids": [{"id":"silo", "count":3}, {"id":"power_shed", "count":2}],
		"relay_trigger_spawned": 6,
		"relay_position": Vector2(980.0, 254.0),
		"relay_health": 9,
		"relay_interval": 4.90,
		"relay_boost_multiplier": 1.30,
		"relay_boost_duration": 3.20,
		"relay_drill_boost": 0.0,
		"relay_scrap": 6,
		"spawn_interval": 1.10,
		"start_delay": 0.65,
		"spawn_mode": "mixed",
	},
	{
		"title": "Wave 6: Final Stand At The Silo",
		"story": "Everything comes in at once. A command drill rig locks onto the signal under the field while shield drones screen the final relay, burrowers tunnel in under the lane, and raiders break for the barn, silo, and power shed under harrier fire.",
		"objective": "Smash the command drill rig and final relay, break the shield screen, stop the tunneling rush, survive 16 attackers, and keep the barn, silo, and power shed alive.",
		"spawn_count": 16,
		"driller_count": 4,
		"harrier_count": 4,
		"shield_count": 3,
		"burrower_count": 3,
		"drill_site": true,
		"drill_rate": 3.10,
		"drill_health": 14,
		"structure_raids": [{"id":"barn", "count":2}, {"id":"power_shed", "count":2}, {"id":"silo", "count":2}],
		"relay_trigger_spawned": 7,
		"relay_position": Vector2(980.0, 302.0),
		"relay_health": 10,
		"relay_interval": 4.50,
		"relay_boost_multiplier": 1.35,
		"relay_boost_duration": 3.50,
		"relay_drill_boost": 6.5,
		"relay_scrap": 7,
		"spawn_interval": 0.92,
		"start_delay": 0.60,
		"spawn_mode": "mixed",
	},
	{
		"title": "Act 2: Excavation Front",
		"story": "The north field finally tears open. A glowing excavation scar splits the rows while two excavation pylons, a fresh rig, and a relay stack try to haul up whatever was buried there.",
		"objective": "Destroy both excavation pylons, then smash the excavation rig and relay while surviving 18 attackers and keeping the power shed online.",
		"spawn_count": 18,
		"driller_count": 4,
		"harrier_count": 4,
		"shield_count": 3,
		"burrower_count": 3,
		"drill_site": true,
		"drill_rate": 3.35,
		"drill_health": 16,
		"structure_raids": [{"id":"power_shed", "count":3}, {"id":"barn", "count":1}],
		"act_two_nodes": [
			{"id":"west_pylon", "name":"West Pylon", "kind":"excavation_pylon", "position":Vector2(480.0, 304.0), "health":8, "pulse_interval":4.60, "primary_value":4.0, "effect":"drill_boost", "scrap":4},
			{"id":"east_pylon", "name":"East Pylon", "kind":"excavation_pylon", "position":Vector2(800.0, 312.0), "health":8, "pulse_interval":4.60, "primary_value":4.0, "effect":"drill_boost", "scrap":4}
		],
		"relay_trigger_spawned": 7,
		"relay_position": Vector2(640.0, 248.0),
		"relay_health": 11,
		"relay_interval": 4.30,
		"relay_boost_multiplier": 1.38,
		"relay_boost_duration": 3.70,
		"relay_drill_boost": 6.5,
		"relay_scrap": 8,
		"spawn_interval": 0.84,
		"start_delay": 0.58,
		"spawn_mode": "mixed",
	},
	{
		"title": "Wave 8: Breach Column",
		"story": "Alien columns march straight out of the excavation scar. Shield drones hold the center while breach beacons start lashing the barn and silo from both sides.",
		"objective": "Destroy the breach beacons and relay mast, survive 20 attackers, and keep the barn and silo standing through the breach assault.",
		"spawn_count": 20,
		"driller_count": 5,
		"harrier_count": 4,
		"shield_count": 4,
		"burrower_count": 4,
		"structure_raids": [{"id":"barn", "count":3}, {"id":"silo", "count":3}],
		"act_two_nodes": [
			{"id":"barn_beacon", "name":"Barn Beacon", "kind":"breach_beacon", "position":Vector2(308.0, 308.0), "health":8, "pulse_interval":4.70, "primary_value":1.0, "effect":"structure_strike", "target_structure_id":"barn", "scrap":4},
			{"id":"silo_beacon", "name":"Silo Beacon", "kind":"breach_beacon", "position":Vector2(972.0, 300.0), "health":8, "pulse_interval":4.70, "primary_value":1.0, "effect":"structure_strike", "target_structure_id":"silo", "scrap":4}
		],
		"relay_trigger_spawned": 8,
		"relay_position": Vector2(320.0, 314.0),
		"relay_health": 12,
		"relay_interval": 4.00,
		"relay_boost_multiplier": 1.40,
		"relay_boost_duration": 3.90,
		"relay_drill_boost": 0.0,
		"relay_scrap": 8,
		"spawn_interval": 0.80,
		"start_delay": 0.55,
		"spawn_mode": "mixed",
	},
	{
		"title": "Wave 9: Core Lift",
		"story": "The invaders start lifting glowing machinery out of the crater. Another heavy rig bites down while twin lift anchors try to keep the rig and relay stabilized under harrier cover.",
		"objective": "Destroy both lift anchors, then the core-lift rig and relay, survive 22 attackers, and stop the farm from collapsing under the split assault.",
		"spawn_count": 22,
		"driller_count": 5,
		"harrier_count": 5,
		"shield_count": 4,
		"burrower_count": 4,
		"drill_site": true,
		"drill_rate": 3.55,
		"drill_health": 18,
		"structure_raids": [{"id":"barn", "count":2}, {"id":"power_shed", "count":2}, {"id":"silo", "count":2}],
		"act_two_nodes": [
			{"id":"west_anchor", "name":"West Anchor", "kind":"lift_anchor", "position":Vector2(502.0, 272.0), "health":9, "pulse_interval":4.40, "primary_value":1.0, "secondary_value":1.0, "effect":"repair_objectives", "scrap":5},
			{"id":"east_anchor", "name":"East Anchor", "kind":"lift_anchor", "position":Vector2(778.0, 272.0), "health":9, "pulse_interval":4.40, "primary_value":1.0, "secondary_value":1.0, "effect":"repair_objectives", "scrap":5}
		],
		"relay_trigger_spawned": 8,
		"relay_position": Vector2(964.0, 268.0),
		"relay_health": 12,
		"relay_interval": 3.90,
		"relay_boost_multiplier": 1.42,
		"relay_boost_duration": 4.00,
		"relay_drill_boost": 7.0,
		"relay_scrap": 9,
		"spawn_interval": 0.76,
		"start_delay": 0.52,
		"spawn_mode": "mixed",
	},
	{
		"title": "Wave 10: Dawn Counterfire",
		"story": "The last extraction wave hits before sunrise. The crater boils with light while three command beacons, the final relay stack, the last excavation rig, and the Overseer command craft drive every surviving alien type at the farm at once.",
		"objective": "Break the command beacons, bring down the Overseer, smash the final excavation rig and relay stack, survive 24 attackers, and hold Miller Farm until dawn.",
		"spawn_count": 24,
		"driller_count": 6,
		"harrier_count": 5,
		"shield_count": 5,
		"burrower_count": 5,
		"drill_site": true,
		"drill_rate": 3.85,
		"drill_health": 20,
		"structure_raids": [{"id":"barn", "count":3}, {"id":"power_shed", "count":3}, {"id":"silo", "count":3}],
		"act_two_nodes": [
			{"id":"left_beacon", "name":"Left Beacon", "kind":"command_beacon", "position":Vector2(414.0, 246.0), "health":10, "pulse_interval":4.00, "primary_value":1.18, "secondary_value":3.40, "tertiary_value":4.0, "effect":"frenzy", "scrap":5},
			{"id":"core_beacon", "name":"Core Beacon", "kind":"command_beacon", "position":Vector2(640.0, 250.0), "health":10, "pulse_interval":4.00, "primary_value":1.18, "secondary_value":3.40, "tertiary_value":4.0, "effect":"frenzy", "scrap":5},
			{"id":"right_beacon", "name":"Right Beacon", "kind":"command_beacon", "position":Vector2(866.0, 246.0), "health":10, "pulse_interval":4.00, "primary_value":1.18, "secondary_value":3.40, "tertiary_value":4.0, "effect":"frenzy", "scrap":5}
		],
		"relay_trigger_spawned": 9,
		"relay_position": Vector2(640.0, 260.0),
		"relay_health": 13,
		"relay_interval": 3.70,
		"relay_boost_multiplier": 1.45,
		"relay_boost_duration": 4.20,
		"relay_drill_boost": 7.5,
		"relay_scrap": 10,
		"boss": {
			"name":"Overseer",
			"health":34,
			"scrap":14,
			"position":Vector2(640.0, 236.0),
			"patrol_min_x":352.0,
			"patrol_max_x":928.0,
			"hover_base_y":236.0,
			"patrol_speed":108.0,
			"attack_interval":2.20,
			"projectile_speed":442.0,
			"projectile_damage":1,
			"volley_count":2,
			"pulse_interval":6.10,
			"boost_multiplier":1.22,
			"boost_duration":3.90,
			"drill_boost":4.5
		},
		"spawn_interval": 0.72,
		"start_delay": 0.50,
		"spawn_mode": "mixed",
	},
]
