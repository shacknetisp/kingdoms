kingdoms.corestone = {}
-- Any mod can set this flag since they run in one thread.
kingdoms.show_protection_messages = true
-- Helper function to set the message display state.
function kingdoms.spm(s)
    kingdoms.show_protection_messages = s
end

function kingdoms.is_protected(r, pos, name)
    if not name or not pos then return false end
    local kingdom = kingdoms.player.kingdom(name)
    local positions = minetest.find_nodes_in_area(
        {x = pos.x - r, y = pos.y - r, z = pos.z - r},
        {x = pos.x + r, y = pos.y + r, z = pos.z + r},
        {"kingdoms:corestone"})
    for _, pos in ipairs(positions) do
        local meta = minetest.get_meta(pos)
        local kid = meta:get_string("kingdom.id")
        if not kingdom or kid ~= kingdom.id then
            if kingdoms.show_protection_messages then
                minetest.chat_send_player(name, ("This area is part of a kingdom ('%s') of which you are not a member."):format(kingdoms.db.kingdoms[kid].longname))
            end
            return false
        end
    end
    return true
end

local old_is_protected = minetest.is_protected
function minetest.is_protected(pos, digger, digging)
    if not kingdoms.is_protected(kingdoms.config.corestone_radius, pos, digger) then
        if protection_lagporter and digging then
            protection_lagporter.check(pos, digger)
        end
        return true
    end
    return old_is_protected(pos, digger, digging)
end

minetest.register_node("kingdoms:corestone", {
	description = "Kingdom Core",
	drawtype = "nodebox",
	tiles = {
		"moreblocks_circle_stone_bricks.png",
		"moreblocks_circle_stone_bricks.png",
		"moreblocks_circle_stone_bricks.png^protector_logo.png"
	},
	sounds = default.node_sound_stone_defaults(),
	groups = {oddly_breakable_by_hand = 2, unbreakable = 1},
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
            if not kingdom then
                minetest.chat_send_player(placer:get_player_name(), "You cannot place a corestone if you are not part of a kingdom.")
                return itemstack
            end
            
            if pos.y < kingdoms.config.corestone_miny then
                minetest.chat_send_player(placer:get_player_name(), ("You cannot place a corestone below %d."):format(kingdoms.config.corestone_miny))
                return itemstack
            end
            
            local radius = kingdoms.config.corestone_radius * 4
            
            kingdoms.spm(false)
            local canplace = not protector.is_protected(radius, pointed_thing.under, placer:get_player_name()) or not protector.is_protected(radius, pointed_thing.above, placer:get_player_name())
            kingdoms.spm(true)
            if canplace then
                minetest.chat_send_player(placer:get_player_name(), "You cannot place a corestone this close to another.")
                return itemstack
            end
            
            return minetest.item_place(itemstack, placer, pointed_thing)
        end,

	after_place_node = function(pos, placer)
            local kingdom = kingdoms.player.kingdom(placer:get_player_name())
            local meta = minetest.get_meta(pos)
            meta:set_string("kingdom.id", kingdom.id)
            meta:set_string("infotext", ("Corestone of %s"):format(kingdom.longname))
	end,

	on_use = function(itemstack, user, pointed_thing)
	end,

	on_rightclick = function(pos, node, clicker, itemstack)
	end,

	on_punch = function(pos, node, puncher)
	end,
})
