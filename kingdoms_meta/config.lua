function kingdoms.config_table(mod)
    -- Base table for configuration.
    local ret = {
        _defaults = {},
    }

    -- Check if a setting is defined in minetest.conf
    function ret._get(setting, default)
        if type(default) == "boolean" then
            local read = minetest.setting_getbool(mod.."."..setting)
            if read == nil then
                    return default
            else
                    return read
            end
        elseif type(default) == "string" then
            return minetest.setting_get(mod.."."..setting) or default
        elseif type(default) == "number" then
            return tonumber(minetest.setting_get(mod.."."..setting) or default)
        end
    end

    -- To set a default value: <table>.setting_name = value
    -- To get the default value or what is specified in minetest.conf: <table>.setting_name
    setmetatable(ret, {
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
    return ret
end
