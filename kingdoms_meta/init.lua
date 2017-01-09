local modpath = minetest.get_modpath("kingdoms_meta")
local function domodfile(f)
    dofile(modpath .. '/' .. f)
end

kingdoms = {}

function kingdoms.log_function(mod)
    return function(level, message) minetest.log(level, "["..mod.."] "..message) end
end

domodfile("config.lua")

local mod_ready_registry = {}
local has_loaded = {}

function kingdoms.mod_ready(mod)
    has_loaded[mod] = true
    if mod_ready_registry[mod] then
        for _,f in ipairs(mod_ready_registry[mod]) do
            if f.params then
                f.func(unpack(f.params))
            else
                f.func()
            end
        end
    end
end

function kingdoms.at_mod_load(mod, func, ...)
    if has_loaded[mod] then
        return func(...)
    end
    mod_ready_registry[mod] = mod_ready_registry[mod] or {}
    table.insert(mod_ready_registry[mod], {
        func = func,
        params = {...},
    })
end
