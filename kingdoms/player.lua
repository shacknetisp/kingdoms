kingdoms.player = {}
kingdoms.db.players = kingdoms.db.players or {}
kingdoms.db.invitations = kingdoms.db.invitations or {}

function kingdoms.player.kingdom(name)
    return kingdoms.db.kingdoms[kingdoms.db.players[name]]
end

function kingdoms.player.kingdom_state(name)
    local kingdom = kingdoms.player.kingdom(name)
    if not kingdom then return nil end
    return kingdom.members[name]
end

function kingdoms.player.can(name, level)
    local kingdom = kingdoms.player.kingdom(name)
    if not kingdom then return false end
    if not kingdom.levels[level] then
        kingdom.levels[level] = kingdoms.config["default_level_"..level]
    end
    local check = kingdom.levels[level]
    return (kingdom.members[name].level >= check)
end

function kingdoms.player.canpos(pos, name, level)
    local akingdom = kingdoms.bypos(pos)
    local pkingdom = kingdoms.player.kingdom(name)
    if not akingdom then
        return true
    end
    if not pkingdom then
        return false
    end
    if akingdom.id ~= pkingdom.id then
        return false
    end
    return kingdoms.player.can(name, level)
end


local function respawn(player)
    local kingdom = kingdoms.player.kingdom(player:get_player_name())
    if kingdom and kingdom.corestone.pos then
        kingdoms.log("action", "Respawning "..player:get_player_name().." at corestone "..minetest.pos_to_string(kingdom.corestone.pos).." of '"..kingdom.longname.."'")
        player:setpos(vector.add(kingdom.corestone.pos, {x=0, y=1, z=0}))
        return true
    elseif kingdoms.db.servercorestone then
        kingdoms.log("action", "Respawning "..player:get_player_name().." at server corestone "..minetest.pos_to_string(kingdoms.db.servercorestone)..".")
        player:setpos(vector.add(kingdoms.db.servercorestone, {x=0, y=1, z=0}))
        return true
    end
    return false
end

minetest.register_on_newplayer(respawn)
minetest.register_on_respawnplayer(respawn)
