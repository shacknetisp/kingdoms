-- Function to execute more files.
local modpath = minetest.get_modpath("kingdoms")
local function domodfile(f)
    dofile(modpath .. '/' .. f)
end

kingdoms.config = kingdoms.config_table("kingdoms")
kingdoms.log = kingdoms.log_function("kingdoms")
domodfile("defaults.lua")

-- Persistent database.
kingdoms.db = {}

-- Contains meta functions operating on the database.
kingdoms.dbmeta = {}
kingdoms.dbmeta.file = minetest.get_worldpath() .. "/kingdoms_db"

function kingdoms.dbmeta.load()
    local file = io.open(kingdoms.dbmeta.file)
    if file then
        kingdoms.db = minetest.deserialize(file:read("*all")) or {}
        file:close()
        kingdoms.log("action", "Loading database.")
    else
        kingdoms.log("warning", "Database did not exist.")
    end
end

function kingdoms.dbmeta.save()
    local f = io.open(kingdoms.dbmeta.file, "w")
    f:write(minetest.serialize(kingdoms.db))
    f:close()
    kingdoms.log("info", "Saved database.")
end

function kingdoms.dbmeta.save_after()
    minetest.after(kingdoms.config.save_delay, kingdoms.dbmeta.save_after)
    kingdoms.dbmeta.save()
end

-- Preform the initial load of the database.
kingdoms.dbmeta.load()

-- Save at regular intervals and upon shutdown.
minetest.after(kingdoms.config.save_delay, kingdoms.dbmeta.save_after)

domodfile("utils.lua")

domodfile("kingdom.lua")
domodfile("player.lua")
domodfile("chat.lua")
domodfile("nametags.lua")

domodfile("hud.lua")
domodfile("corestone.lua")
domodfile("gen.lua")
domodfile("barriers.lua")

-- Overrides of default to support kingdoms.
domodfile("ext/chests.lua")
domodfile("ext/furnace.lua")
-- Silver without moreores.
domodfile("ext/silver.lua")

domodfile("crafts.lua")

-- 3d_armor
ARMOR_HEAL_MULTIPLIER = 0

minetest.register_on_shutdown(kingdoms.dbmeta.save)

-- All done!
kingdoms.log("action", "Completely loaded.")
kingdoms.log("action", "Number of kingdoms in the database: "..tostring(kingdoms.utils.table_len(kingdoms.db.kingdoms)))
kingdoms.log("action", "Number of players in kingdoms: "..tostring(kingdoms.utils.table_len(kingdoms.db.players)))
kingdoms.mod_ready("kingdoms")
