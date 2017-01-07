local teleporting = {}
minetest.register_globalstep(function(dtime)
    for _, player in pairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        local tp = teleporting[name]
        if tp then
            tp.timer = tp.timer + dtime
            if vector.distance(player:getpos(), tp.start) > 0.1 then
                magic.cancel_teleportation(name)
            elseif tp.timer >= tp.delay then
                minetest.registered_items[tp.item].original.go(player)
                teleporting[name] = nil
            end
        end
    end
end)

function magic.start_teleportation(player, item, delay)
    local name = player:get_player_name()
    if teleporting[name] then
        magic.cancel_teleportation(name)
    end
    teleporting[name] = {
        timer = 0,
        delay = delay,
        item = item,
        start = player:getpos(),
    }
    minetest.chat_send_player(name, "Teleportation will occur in "..tostring(delay).." seconds. Remain still.")
end

function magic.cancel_teleportation(name)
    minetest.chat_send_player(name, "Teleportation has been canceled.")
    teleporting[name] = nil
end

minetest.register_on_leaveplayer(function(player)
    magic.cancel_teleportation(player:get_player_name())
end)

magic.register_spell("magic:spell_teleport_spawn", {
    description = "Spawn Teleportation Spell",
    type = "action",
    color = "#0A0",
    emblem = "action",
    cost = 15,
    on_use = function(itemstack, player)
        magic.start_teleportation(player, itemstack:get_name(), magic.config.teleportation_delay)
        return true
    end,
    go = function(player)
        if not kingdoms.db.servercorestone then
            minetest.chat_send_player(player:get_player_name(), "There is no destination.")
            return
        end
        player:setpos(vector.add(kingdoms.db.servercorestone, {x=0, y=1, z=0}))
    end,
})
minetest.register_craft({
    output = "magic:spell_teleport_spawn",
    recipe = {
        {"magic:concentrated_warp_essence", "magic:control_essence"},
        {"group:minor_spellbinding", "default:sapling"},
    },
})

magic.register_spell("magic:spell_teleport_kingdom", {
    description = "Kingdom Teleportation Spell",
    type = "action",
    color = "#FA0",
    emblem = "action",
    cost = 15,
    on_use = function(itemstack, player)
        magic.start_teleportation(player, itemstack:get_name(), magic.config.teleportation_delay)
        return true
    end,
    go = function(player)
        local kingdom = kingdoms.player.kingdom(player:get_player_name())
        if not kingdom or not kingdom.corestone.pos then
            minetest.chat_send_player(player:get_player_name(), "There is no destination.")
            return
        end
        player:setpos(vector.add(kingdom.corestone.pos, {x=0, y=1, z=0}))
    end,
})
minetest.register_craft({
    output = "magic:spell_teleport_kingdom",
    recipe = {
        {"magic:concentrated_warp_essence", "magic:control_essence"},
        {"group:minor_spellbinding", "default:junglesapling"},
    },
})
