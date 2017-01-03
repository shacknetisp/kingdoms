-- Save the database every <save_delay> seconds.
kingdoms.config.save_delay = 10

-- Maximum kingdom name length.
kingdoms.config.max_name_length = 128

-- Minimum and maximum level (inclusive).
kingdoms.config.minlevel = 1
kingdoms.config.maxlevel = 100

-- Default levels.
kingdoms.config.default_level_set_levels = 100 -- Change level values.
kingdoms.config.default_level_corestone = 100 -- Place or dig the corestone.
kingdoms.config.default_level_set_info = 75 -- Set the kingdom's info.
kingdoms.config.default_level_kick = 50 -- Kick a member of lower level than oneself.
kingdoms.config.default_level_invite = 50 -- Invite someone to join.
kingdoms.config.default_level_change_level = 25 -- Change someone's level if their level and the target level are lower than oneself.
kingdoms.config.default_level_build = 10 -- Build within the corestone's range.
kingdoms.config.default_level_talk = 1 -- Talk in the kingdom's main channel.

-- A corestone extends in a radius of <corestone_radius>.
kingdoms.config.corestone_radius = 5
kingdoms.config.corestone_overlap_multiplier = 4
-- A corestone can be placed only above <corestone_miny>.
kingdoms.config.corestone_miny = -32
