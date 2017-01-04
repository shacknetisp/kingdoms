local timer = 0

minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer < 0.1 then return end
    timer = 0
    
    for _, player in pairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        local kingdom = kingdoms.player.kingdom(name)
        player:set_nametag_attributes({
            text = kingdom and (name.." ["..kingdom.longname.."]") or name
        })
    end
end)

minetest.setting_set("player_transfer_distance", kingdoms.config.player_visible_distance)
