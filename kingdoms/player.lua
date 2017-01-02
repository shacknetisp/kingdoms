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


local function respawn(player)
    local kingdom = kingdoms.player.kingdom(player:get_player_name())
    if not kingdom or not kingdom.corestone then return false end
    kingdoms.log("action", "Respawning "..player:get_player_name().." at corestone "..minetest.pos_to_string(kingdom.corestone).." of '"..kingdom.longname.."'")
    player:setpos(vector.add(kingdom.corestone, {x=0, y=1, z=0}))
    return true
end

minetest.register_on_respawnplayer(respawn)
