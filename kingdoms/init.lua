-- Function to execute more files.
local modpath = minetest.get_modpath("kingdoms")
local function domodfile(f)
    dofile(modpath .. '/' .. f)
end

-- Mod namespace.
kingdoms = {}

function kingdoms.log(level, message)
    minetest.log(level, "[kingdoms] "..message)
end

-- Initial configuration files.
domodfile("config.lua")
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
minetest.register_on_shutdown(kingdoms.dbmeta.save)

domodfile("utils.lua")

domodfile("kingdom.lua")
domodfile("player.lua")

domodfile("hud.lua")
domodfile("corestone.lua")
domodfile("gen.lua")
domodfile("crafts.lua")

-- All done!
kingdoms.log("action", "Completely loaded.")
