function magic.register_spell(name, def)
    local item_def = {
        description = def.description,
        inventory_image = "magic_essence.png^[colorize:"..def.color..":"..tostring(0xCC).."^magic_emblem_"..def.emblem..".png",
        groups = def.groups or {spell = 1},
    }
    if def.type == "missile" then
        magic.register_missile(name.."_missile", item_def.inventory_image, def)
        item_def.on_use = function(itemstack, player, pointed_thing)
            local playerpos = player:getpos()
            local obj = minetest.add_entity({x=playerpos.x,y=playerpos.y+1.4,z=playerpos.z}, name.."_missile")
            local dir = player:get_look_dir()
            obj:setvelocity({x=dir.x*def.speed, y=dir.y*def.speed, z=dir.z*def.speed})
            obj:setacceleration({x=dir.x*-3, y=-8.5*def.gravity, z=dir.z*-3})
            obj:setyaw(player:get_look_yaw()+math.pi)
            if obj:get_luaentity() then
                obj:get_luaentity().player = player
            else
                obj:remove()
            end
            itemstack:take_item()
            return itemstack
        end
    else
        error("Unknown spell type: "..def.type)
    end
    minetest.register_craftitem(name, item_def)
end
magic.register_spell("magic:spell_fire", {
    description = "Fire Spell",
    type = "missile",
    color = "#F00",
    emblem = "attack",
    speed = 30,
    gravity = 0,
    hit_node = function(self, pos, last_empty_pos)
        local flammable = minetest.get_item_group(minetest.get_node(pos).name, "flammable")
        if flammable > 0 then
            minetest.set_node(pos, {name = "fire:basic_flame"})
            return true
        elseif last_empty_pos then
            minetest.set_node(last_empty_pos, {name = "fire:basic_flame"})
            return true
        end
        return false
    end,
})
minetest.register_craft({
    output = "magic:spell_fire",
    recipe = {
        {"magic:rage_essence", "group:minor_spellbinding"},
    },
})
