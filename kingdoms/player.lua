kingdoms.player = {}
kingdoms.db.players = kingdoms.db.players or {}
kingdoms.db.invites = kingdoms.db.invites or {}

minetest.register_on_joinplayer(function(player)
    kingdoms.db.invites[player:get_player_name()] = kingdoms.db.invites[player:get_player_name()] or {}
end)

function kingdoms.player.kingdom(name)
    return kingdoms.db.kingdoms[kingdoms.db.players[name]]
end

function kingdoms.player.kingdom_state(name)
    local kingdom = kingdoms.player.kingdom(name)
    if not kingdom then return nil end
    return kingdom.members[name]
end
