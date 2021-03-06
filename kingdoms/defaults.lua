-- Save the database every <save_delay> seconds.
kingdoms.config.save_delay = 10

-- Set appropriate mapgen type/flags automatically?
kingdoms.config.mapgen = true

-- Maximum kingdom name length.
kingdoms.config.max_name_length = 128

-- Minimum and maximum level (inclusive).
kingdoms.config.minlevel = 1
kingdoms.config.maxlevel = 100

-- Default levels.
--- Kingdom
kingdoms.config.default_level_set_levels = 100 -- Change level values.
kingdoms.config.default_level_rename = 100 -- Rename the kingdom.
kingdoms.config.default_level_set_info = 75 -- Set the kingdom's info.
kingdoms.config.default_level_friendlies = 75 -- Change the friendly list.
kingdoms.config.default_level_kick = 50 -- Kick a member of lower level than oneself.
kingdoms.config.default_level_invite = 50 -- Invite someone to join.
kingdoms.config.default_level_change_level = 25 -- Change someone's level if their level and the target level are lower than oneself.

--- Node
kingdoms.config.default_level_corestone = 100 -- Place or dig the corestone.
kingdoms.config.default_level_heavy_chests = 15 -- Open heavy locked chests within the corestone's range.
kingdoms.config.default_level_heavy_doors = 15 -- Open heavy locked doors within the corestone's range.
kingdoms.config.default_level_build = 10 -- Build within the corestone's range.

--- Basic
kingdoms.config.default_level_devices = 1 -- Use devices within the corestone's range.
kingdoms.config.default_level_chests = 1 -- Open locked chests within the corestone's range.
kingdoms.config.default_level_doors = 1 -- Open locked doors within the corestone's range.
kingdoms.config.default_level_talk = 1 -- Talk in the kingdom's main channel.

-- A corestone extends in a radius of <corestone_radius>.
kingdoms.config.corestone_radius = 32
kingdoms.config.corestone_overlap_multiplier = 3
-- A corestone can be placed only above <corestone_miny>.
kingdoms.config.corestone_miny = -32

-- Distance players are visible (in 16-node blocks)
kingdoms.config.player_visible_distance = 4

-- Distance of around speech. Use <player_visible_distance * 16> to match with player visibility.
kingdoms.config.around = kingdoms.config.player_visible_distance * 16

-- Radius a materializer reaches.
kingdoms.config.materializer_radius = 5
-- Number of levels in materialized blocks.
kingdoms.config.materialized_levels = 4
-- Materializer ABM settings.
kingdoms.config.materialized_abm_interval = 30
kingdoms.config.materialized_abm_chance = 2

-- Corestone score regeneration per second.
kingdoms.config.corestone_score_regen = 5
-- Maximum corestone score.
kingdoms.config.corestone_score_max = (60 * 60 * 24) * 10
-- Corestone score required to place a corestone.
kingdoms.config.corestone_score_threshold = kingdoms.config.corestone_score_max / 10
-- Damage per second of a Disruptor.
kingdoms.config.disruptor_damage = 1
-- Disruptor ABM settings.
kingdoms.config.disruptor_interval = 5
kingdoms.config.disruptor_chance = 2
