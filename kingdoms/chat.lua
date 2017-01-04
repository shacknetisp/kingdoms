kingdoms.db.current_channels = kingdoms.db.current_channels or {}

function kingdoms.current_chat_channel(name)
    return kingdoms.db.current_channels[name] or "a"
end

local function relay(channel, message, allow, logn)
    for _,player in ipairs(minetest.get_connected_players()) do
        if not allow or allow(player) then
            minetest.chat_send_player(player:get_player_name(), "["..channel.."] "..message)
        end
    end
    kingdoms.log("action", ("[CHAT] [%s (%s)] %s"):format(channel, logn, message))
end

local function nm(n, m, i)
    if i then
        return ("<%s (%s)> %s"):format(n, tostring(i), m)
    end
    return ("<%s> %s"):format(n, m)
end

local channels = {
    a = {
        params = "<text>",
        description = "Speak around.",
        privs = {shout = true},
        name = "around",
        func = function(name, text)
            if text == "" then
                kingdoms.db.current_channels[name] = "a"
                return true
            end
            local tplayer = minetest.get_player_by_name(name)
            if tplayer then
                relay("around", nm(name, text), function(player) return vector.distance(tplayer:getpos(), player:getpos()) <= kingdoms.config.around end, minetest.pos_to_string(vector.round(tplayer:getpos())))
            end
            return true
        end,
    },
    c = {
        params = "<text>",
        description = "Speak in the kingdom's channel",
        privs = {shout = true},
        name = "kingdom",
        func = function(name, text)
            if text == "" then
                kingdoms.db.current_channels[name] = "c"
                return true
            end
            local kingdom = kingdoms.player.kingdom(name)
            if not kingdoms.player.can(name, "talk") then
                return false, "You do not have sufficient level to talk."
            end
            relay("kingdom", nm(name, text, kingdoms.player.kingdom_state(name).level), function(player)
                return kingdoms.player.kingdom(player:get_player_name()) and kingdoms.player.kingdom(player:get_player_name()).id == kingdom.id
            end, kingdom.longname)
            return true
        end,
    },
    g = {
        params = "<text>",
        description = "Speak globally.",
        privs = {shout = true},
        name = "global",
        func = function(name, text)
            if text == "" then
                kingdoms.db.current_channels[name] = "g"
                return true
            end
            relay("global", nm(name, text))
            return true
        end,
    }
}
kingdoms.chat_channels = channels

minetest.register_chatcommand("a", channels.a)
minetest.register_chatcommand("around", channels.a)

minetest.register_chatcommand("g", channels.g)
minetest.register_chatcommand("global", channels.g)

minetest.register_chatcommand("c", channels.c)
minetest.register_chatcommand("kc", channels.c)
minetest.register_chatcommand("kingdomchat", channels.c)

minetest.register_on_chat_message(function(name, message)
    if message:sub(1, 1) == "/" then
        return false
    end
    
    if not minetest.check_player_privs(name, channels[kingdoms.current_chat_channel(name)].privs) then
        minetest.chat_send_player(name, "You cannot use this channel.")
        return true
    end
    
    channels[kingdoms.current_chat_channel(name)].func(name, message)
    
    return true
end)
