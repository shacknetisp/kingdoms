-- Base table for configuration.
kingdoms.config = {
    _defaults = {},
}

-- Check if a setting is defined in minetest.conf
function kingdoms.config._get(setting, default)
    if type(default) == "boolean" then
        local read = minetest.setting_getbool("kingdoms."..setting)
        if read == nil then
                return default
        else
                return read
        end
    elseif type(default) == "string" then
        return minetest.setting_get("kingdoms."..setting) or default
    elseif type(default) == "number" then
        return tonumber(minetest.setting_get("kingdoms."..setting) or default)
    end
end

-- To set a default value: kingdoms.config.setting_name = value
-- To get the default value or what is specified in minetest.conf: kingdoms.config.setting_name
setmetatable(kingdoms.config, {
    __index = function(t, key)
        local default = t._defaults[key]
        -- If there is no default then the setting should not be used.
        if default == nil then
            return error(("'%s' is not a configuration option"):format(key))
        end
        return t._get(key, default)
    end,
    __newindex = function(t, key, value)
        t._defaults[key] = value
    end,
})

-- Generate a dynamic list of default level names.
function kingdoms.possible_levels()
    local ret = {}
    for k,v in kingdoms.utils.spairs(kingdoms.config._defaults, function(t, a, b) return (t[a] == t[b]) and (a < b) or (t[a] > t[b]) end) do
        local value = string.match(k, "default_level_(.*)")
        if value then
            table.insert(ret, value)
        end
    end
    return ret
end
