-- Function to execute more files.
local modpath = minetest.get_modpath("magic")
local function domodfile(f)
    dofile(modpath .. '/' .. f)
end

-- Mod namespace.
magic = {}

magic.config = kingdoms.config_table("magic")
magic.log = kingdoms.log_function("magic")
domodfile("defaults.lua")

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

domodfile("mana.lua")
domodfile("throwing.lua")
domodfile("mapgen.lua")

domodfile("crafts.lua")

domodfile("timegens.lua")
domodfile("crystals.lua")
domodfile("spells.lua")
domodfile("turrets.lua")

domodfile("spells/action.lua")
domodfile("spells/attack.lua")
domodfile("spells/defense.lua")

magic.log("action", "Loaded.")
kingdoms.mod_ready("magic")
