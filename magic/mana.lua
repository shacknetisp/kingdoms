magic.manadb = {}
local huds = {}
local timer = 0

minetest.after(0, function()
    kingdoms.db.magic_mana = kingdoms.db.magic_mana or {}
    magic.manadb = kingdoms.db.magic_mana
end)

minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer < 0.1 then return end
    timer = 0

    for _, player in pairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        local p = magic.manadb[name]
        p.timer = p.timer + dtime
        if p.timer > 6 then
            p.mana = math.min(p.max_mana, p.mana + (p.timer / 6))
            p.timer = 0
        end
        local hud = huds[name]
        if not hud then
            hud = {}
            huds[name] = hud
            hud.id = player:hud_add({
                name = "mana",
                hud_elem_type = "statbar",
                position = {x = 0.5, y = 1},
                size = {x = 24, y = 24},
                text = "magic_essence.png^[colorize:#00A:200",
                number = p.mana,
                alignment = {x = -1, y = -1},
                offset = {x = -266, y = -110 - 24},
                max = 0,
            })
            hud.oldvalue = p.mana
            return
        elseif hud.oldvalue ~= p.mana then
            player:hud_change(hud.id, "number", p.mana)
            hud.oldvalue = p.mana
        end
    end
end)

function magic.require_mana(player, cost, message)
    local p = magic.manadb[player:get_player_name()]
    if not p then return false end
    if p.mana < cost then
        if message then minetest.chat_send_player(player:get_player_name(), "You do not have enough mana.") end
        return false
    end
    p.mana = math.max(0, p.mana - cost)
    return true
end

function magic.require_energy(player, cost, message)
    local p = magic.manadb[player:get_player_name()]
    if not p then return false end
    local didmana = magic.require_mana(player, cost)
    if didmana then return true end
    if player:get_hp() <= cost then
        if message then minetest.chat_send_player(player:get_player_name(), "You do not have enough health.") end
        return false
    end
    player:set_hp(player:get_hp() - cost)
    return true
end

minetest.register_on_joinplayer(function(player)
    magic.manadb[player:get_player_name()] = magic.manadb[player:get_player_name()] or {
        mana = kingdoms.config.max_mana,
        max_mana = kingdoms.config.max_mana,
        timer = 0,
    }
end)
minetest.register_on_leaveplayer(function(player)
    huds[player:get_player_name()] = nil
end)
