-- Function to execute more files.
local modpath = minetest.get_modpath("magic")
local function domodfile(f)
    dofile(modpath .. '/' .. f)
end

-- Mod namespace.
magic = {}

kingdoms.log("action", "Magic loaded.")
