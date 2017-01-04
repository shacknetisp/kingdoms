-- Save the database every <save_delay> seconds.
kingdoms.config.save_delay = 10

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
kingdoms.config.default_level_kick = 50 -- Kick a member of lower level than oneself.
kingdoms.config.default_level_invite = 50 -- Invite someone to join.
kingdoms.config.default_level_change_level = 25 -- Change someone's level if their level and the target level are lower than oneself.

--- Node
kingdoms.config.default_level_corestone = 100 -- Place or dig the corestone.
kingdoms.config.default_level_heavy_chests = 15 -- Open heavy locked chests within the corestone's range.
kingdoms.config.default_level_heavy_doors = 15 -- Open heavy locked doors within the corestone's range.
kingdoms.config.default_level_build = 10 -- Build within the corestone's range.

--- Basic
kingdoms.config.default_level_furnaces = 1 -- Use furnaces within the corestone's range.
kingdoms.config.default_level_chests = 1 -- Open locked chests within the corestone's range.
kingdoms.config.default_level_doors = 1 -- Open locked doors within the corestone's range.
kingdoms.config.default_level_talk = 1 -- Talk in the kingdom's main channel.

-- A corestone extends in a radius of <corestone_radius>.
kingdoms.config.corestone_radius = 5
kingdoms.config.corestone_overlap_multiplier = 4
-- A corestone can be placed only above <corestone_miny>.
kingdoms.config.corestone_miny = -32

-- Distance players are visible (in 16-node blocks)
kingdoms.config.player_visible_distance = 4

-- Distance of around speech. Use <player_visible_distance * 16> to match with player visibility.
kingdoms.config.around = kingdoms.config.player_visible_distance * 16
