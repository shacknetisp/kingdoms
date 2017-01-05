kingdoms.corestone = {}
kingdoms.db.corestones = kingdoms.db.corestones or {}
-- Any mod can set this flag since they run in one thread.
kingdoms.show_protection_messages = true
-- Helper function to set the message display state.
function kingdoms.spm(s)
    kingdoms.show_protection_messages = s
end

function kingdoms.near_pos(r, pos)
    local ret = {}
    for k,v in pairs(kingdoms.db.corestones) do
        local a = {x = v.x - r, y = v.y - r, z = v.z - r}
        local b = {x = v.x + r, y = v.y + r, z = v.z + r}
        if pos.x >= a.x and pos.x <= b.x and pos.y >= a.y and pos.y <= b.y and pos.z >= a.z and pos.z <= b.z then
            table.insert(ret, v)
        end
    end
    return ret
end

function kingdoms.can_dig(r, pos, name)
    if not name or not pos then return false end
    local kingdom = kingdoms.player.kingdom(name)
    local positions = kingdoms.near_pos(r, pos)
    for _, pos in ipairs(positions) do
        local nodename = minetest.get_node(pos).name
        -- If this is the server spawn, nobody can dig here.
        if nodename == "kingdoms:servercorestone" then
            return false
        end
        local meta = minetest.get_meta(pos)
        local kid = meta:get_string("kingdom.id")
        if (not kingdom or kid ~= kingdom.id) and kingdoms.db.kingdoms[kid] then
            if kingdoms.show_protection_messages then
                minetest.chat_send_player(name, ("This area is part of a kingdom ('%s') of which you are not a member."):format(kingdoms.db.kingdoms[kid].longname))
            end
            return false
        end
        if not kingdoms.player.can(name, "build") then
            if kingdoms.show_protection_messages then
                minetest.chat_send_player(name, "You are not of a sufficient level to build here.")
            end
            return false
        end
    end
    return true
end

function kingdoms.check_claimward(r, pos, name)
    if not name or not pos then return false end
    local kingdom = kingdoms.player.kingdom(name)
    local positions = minetest.find_nodes_in_area(
        {x = pos.x - r, y = pos.y - r, z = pos.z - r},
        {x = pos.x + r, y = pos.y + r, z = pos.z + r},
        {"kingdoms:claimward"})
    for _, pos in ipairs(positions) do
        local nodename = minetest.get_node(pos).name
        local meta = minetest.get_meta(pos)
        local kid = meta:get_string("kingdom.id")
        if (not kingdom or kid ~= kingdom.id) and kingdoms.db.kingdoms[kid] then
            return false
        end
    end
    return true
end

function kingdoms.check_pos_level(pos, name, level, message)
    local akingdom = kingdoms.bypos(pos)
    local pkingdom = kingdoms.player.kingdom(name)
    if not akingdom or (akingdom == pkingdom and kingdoms.player.can(name, level)) then
        return true
    else
        if message then
            minetest.chat_send_player(name, message)
        end
        return false
    end
end

function kingdoms.bypos(pos, radius)
    local r = radius or kingdoms.config.corestone_radius
    local positions = kingdoms.near_pos(r, pos)
    for _, pos in ipairs(positions) do
        local meta = minetest.get_meta(pos)
        if kingdoms.db.kingdoms[meta:get_string("kingdom.id")] then
            return kingdoms.db.kingdoms[meta:get_string("kingdom.id")]
        end
    end
    return nil
end

function kingdoms.bycspos(pos)
    local meta = minetest.get_meta(pos)
    return kingdoms.db.kingdoms[meta:get_string("kingdom.id")]
end

function kingdoms.is_protected(pos, digger)
    return not kingdoms.can_dig(kingdoms.config.corestone_radius, pos, digger)
end

old_is_protected = minetest.is_protected
function minetest.is_protected(pos, digger, digging)
    -- If this is an admin, they can dig anywhere without a message.
    if minetest.check_player_privs(digger, {protection_bypass = true}) then
        return false
    end
    if kingdoms.is_protected(pos, digger) then
        if _G['protection_lagporter'] ~= nil and digging then
            protection_lagporter.check(pos, digger)
        end
        return true
    end
    return old_is_protected(pos, digger, digging)
end

-- Build the Corestone infotext, do not resend meta if unnecessary.
local function build_infotext(pos, nodename)
    local meta = minetest.get_meta(pos)
    local akingdom = kingdoms.db.kingdoms[meta:get_string("kingdom.id")]
    local infotext = ""
    if akingdom then
        infotext = nodename.." of "..akingdom.longname
    else
        infotext = "Inactive "..nodename
    end
    if meta:get_string("infotext") ~= infotext then
        meta:set_string("infotext", infotext)
    end
end

minetest.register_node("kingdoms:corestone", {
    description = "Kingdom Core",
    drawtype = "nodebox",
    tiles = {"kingdoms_corestone.png"},
    sounds = default.node_sound_stone_defaults(),
    groups = {oddly_breakable_by_hand = 2, unbreakable = 1, kingdom_infotext = 1},
    is_ground_content = false,
    paramtype = "light",
    light_source = 0,

    node_box = {
        type = "fixed",
        fixed = {
            {-0.5 ,-0.5, -0.5, 0.5, 0.5, 0.5},
        }
    },

    on_blast = function(a, b)
        return
    end,

    on_place = function(itemstack, placer, pointed_thing)
        if not placer or pointed_thing.type ~= "node" then
            return itemstack
        end

        local kingdom = kingdoms.player.kingdom(placer:get_player_name())
        if not kingdom or not kingdoms.player.can(placer:get_player_name(), "corestone") then
            minetest.chat_send_player(placer:get_player_name(), "You cannot place a corestone if you are not of sufficient level in a kingdom.")
            return itemstack
        end

        if kingdom.corestone.pos then
            minetest.chat_send_player(placer:get_player_name(), "You cannot place a corestone if the kingdom already has a corestone placed.")
            return itemstack
        end

        if pointed_thing.under.y < kingdoms.config.corestone_miny then
            minetest.chat_send_player(placer:get_player_name(), ("You cannot place a corestone below %d."):format(kingdoms.config.corestone_miny))
            return itemstack
        end

        local radius = kingdoms.config.corestone_radius * kingdoms.config.corestone_overlap_multiplier

        kingdoms.spm(false)
        local cantplace = not kingdoms.can_dig(radius, pointed_thing.under, placer:get_player_name()) or not kingdoms.can_dig(radius, pointed_thing.above, placer:get_player_name())
        local cantplaceward = not kingdoms.check_claimward(kingdoms.config.corestone_radius, pointed_thing.above, placer:get_player_name()) or not kingdoms.check_claimward(kingdoms.config.corestone_radius, pointed_thing.under, placer:get_player_name())
        kingdoms.spm(true)
        if cantplace then
            minetest.chat_send_player(placer:get_player_name(), "You cannot place a corestone this close to another.")
            return itemstack
        end
        if cantplaceward then
            minetest.chat_send_player(placer:get_player_name(), "You cannot place a corestone this close to an opposing claim ward.")
            return itemstack
        end

        kingdoms.db.corestones[minetest.pos_to_string(pointed_thing.above)] = pointed_thing.above

        kingdom.corestone.pos = pointed_thing.above
        kingdom.corestone.placed = os.time()
        kingdoms.log("action", ("Corestone of '%s' placed at %s."):format(kingdom.longname, minetest.pos_to_string(pointed_thing.above)))

        return minetest.item_place(itemstack, placer, pointed_thing)
    end,

    after_place_node = function(pos, placer)
        local kingdom = kingdoms.player.kingdom(placer:get_player_name())
        local meta = minetest.get_meta(pos)
        meta:set_string("kingdom.id", kingdom.id)
    end,

    can_dig = function(pos, digger)
        local akingdom = kingdoms.bycspos(pos)
        local pkingdom = kingdoms.player.kingdom(digger:get_player_name())
        -- Can only dig if this is the digger's kingdom and he has enough levels.
        return not akingdom or (pkingdom and pkingdom.id == akingdom.id and kingdoms.player.can(digger:get_player_name(), "corestone"))
    end,

    on_destruct = function(pos)
        kingdoms.db.corestones[minetest.pos_to_string(pos)] = nil
        local kingdom = kingdoms.bycspos(pos)
        if not kingdom then return end
        kingdom.corestone.pos = nil
        kingdom.corestone.dug = os.time()
        kingdoms.log("action", ("Corestone of '%s' removed at %s."):format(kingdom.longname, minetest.pos_to_string(pos)))
    end,

    on_rightclick = function(pos, node, clicker, itemstack)
        local akingdom = kingdoms.bycspos(pos)
        if akingdom then
            kingdoms.formspec_info.func(clicker:get_player_name(), akingdom)
        end
    end,
})

minetest.register_node("kingdoms:claimward", {
    description = "Claim Ward",
    drawtype = "nodebox",
    tiles = {"kingdoms_claimward.png"},
    sounds = default.node_sound_stone_defaults(),
    groups = {oddly_breakable_by_hand = 2, unbreakable = 1, kingdom_infotext = 1},
    is_ground_content = false,
    paramtype = "light",
    light_source = 0,

    node_box = {
        type = "fixed",
        fixed = {
            {-0.5 ,-0.5, -0.5, 0.5, 0.5, 0.5},
        }
    },

    on_place = function(itemstack, placer, pointed_thing)
        if not placer or pointed_thing.type ~= "node" then
            return itemstack
        end

        local kingdom = kingdoms.player.kingdom(placer:get_player_name())
        if not kingdom then
            minetest.chat_send_player(placer:get_player_name(), "You cannot place a ward if you are not a member of a kingdom.")
            return itemstack
        end

        local radius = kingdoms.config.corestone_radius

        kingdoms.spm(false)
        local cantplace = not kingdoms.can_dig(radius, pointed_thing.under, placer:get_player_name()) or not kingdoms.can_dig(radius, pointed_thing.above, placer:get_player_name())
        kingdoms.spm(true)
        if cantplace then
            minetest.chat_send_player(placer:get_player_name(), "You cannot place a ward this close to another corestone.")
            return itemstack
        end

        return minetest.item_place(itemstack, placer, pointed_thing)
    end,

    after_place_node = function(pos, placer)
        local kingdom = kingdoms.player.kingdom(placer:get_player_name())
        local meta = minetest.get_meta(pos)
        meta:set_string("kingdom.id", kingdom.id)
    end,
})

minetest.register_node("kingdoms:servercorestone", {
    description = "Server Core",
    drawtype = "nodebox",
    tiles = {"kingdoms_corestone.png"},
    sounds = default.node_sound_stone_defaults(),
    groups = {oddly_breakable_by_hand = 2, unbreakable = 1, not_in_creative_inventory = 1},
    is_ground_content = false,
    paramtype = "light",
    light_source = 0,

    node_box = {
        type = "fixed",
        fixed = {
            {-0.5 ,-0.5, -0.5, 0.5, 0.5, 0.5},
        }
    },

    on_blast = function(a, b)
        return
    end,

    on_place = function(itemstack, placer, pointed_thing)
        if not placer or pointed_thing.type ~= "node" then
            return itemstack
        end

        if not minetest.check_player_privs(placer:get_player_name(), {server = true}) then
            minetest.chat_send_player(placer:get_player_name(), "You cannot place a server corestone. How did you even get it?")
            return itemstack
        end

        if kingdoms.db.servercorestone then
            minetest.chat_send_player(placer:get_player_name(), "You cannot place a server corestone if there is already one placed.")
            return itemstack
        end

        -- Even the server corestone cannot overlap already existent corestones.
        local radius = kingdoms.config.corestone_radius * kingdoms.config.corestone_overlap_multiplier

        kingdoms.spm(false)
        local cantplace = not kingdoms.can_dig(radius, pointed_thing.under, placer:get_player_name()) or not kingdoms.can_dig(radius, pointed_thing.above, placer:get_player_name())
        local cantplaceward = not kingdoms.check_claimward(kingdoms.config.corestone_radius, pointed_thing.above, placer:get_player_name()) or not kingdoms.check_claimward(kingdoms.config.corestone_radius, pointed_thing.under, placer:get_player_name())
        kingdoms.spm(true)
        if cantplace then
            minetest.chat_send_player(placer:get_player_name(), "You cannot place a corestone this close to another.")
            return itemstack
        end
        if cantplaceward then
            minetest.chat_send_player(placer:get_player_name(), "You cannot place a corestone this close to an opposing claim ward.")
            return itemstack
        end

        kingdoms.db.corestones[minetest.pos_to_string(pointed_thing.above)] = pointed_thing.above

        kingdoms.db.servercorestone = pointed_thing.above

        return minetest.item_place(itemstack, placer, pointed_thing)
    end,

    after_place_node = function(pos, placer)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Server Spawn")
    end,

    can_dig = function(pos, digger)
        return minetest.check_player_privs(digger:get_player_name(), {server = true})
    end,

    on_destruct = function(pos)
        kingdoms.db.corestones[minetest.pos_to_string(pos)] = nil
        kingdoms.db.servercorestone = nil
    end,

    on_rightclick = function(pos, node, clicker)
        minetest.show_formspec(clicker:get_player_name(), "kingdoms:kingdoms_info",
            "size[6,6]"
            .."textarea[0.4,0.25;5.75,6.75;info;Info;"..minetest.formspec_escape(
[[This is some help text.]]).."]"
        )
    end,
})

minetest.register_abm{
    nodenames = {"group:kingdom_infotext"},
    interval = 1,
    chance = 1,
    action = function(pos, node) build_infotext(pos, minetest.registered_nodes[node.name].description) end,
}
