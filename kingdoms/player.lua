kingdoms.player = {}
kingdoms.db.players = {}

function kingdoms.player.kingdom(name)
    return kingdoms.db.players[name]
end
