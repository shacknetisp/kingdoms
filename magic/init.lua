-- Function to execute more files.
local modpath = minetest.get_modpath("magic")
local function domodfile(f)
    dofile(modpath .. '/' .. f)
end

-- Mod namespace.
magic = {}

function magic.log(level, message)
    minetest.log(level, "[magic] "..message)
end

local mese_mesecons = rawget(_G, "mesecon") and {conductor = {
    state = mesecon.state.off,
    onstate = "mesecons_extrawires:mese_powered",
    rules = mesewire_rules
    }} or nil
minetest.override_item("default:mese", {
	mesecons = mese_mesecons,
        -- Mese is too strong to be used for minor spellbinding.
        groups = {cracky = 1, level = 2, major_spellbinding = 1},
})

domodfile("crafts.lua")
domodfile("crystals.lua")
domodfile("spells.lua")
domodfile("timegens.lua")
domodfile("mapgen.lua")

magic.log("action", "Loaded.")
