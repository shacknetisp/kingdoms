function magic.register_spell(name, def)
    local item_def = {
        description = def.description..(" (%d)"):format(def.cost),
        inventory_image = "magic_essence.png^[colorize:"..def.color..":"..tostring(0xCC).."^magic_emblem_"..def.emblem..".png",
        groups = def.groups or {spell = 1},
    }
    local function docost(player)
        -- If the spell is harmful, it will dip into player health when mana runs out.
        if def.harmful then
            return magic.require_energy(player, def.cost, true)
        else
            return magic.require_mana(player, def.cost, true)
        end
    end
    if def.type == "missile" then
        local f = magic.register_missile(name.."_missile", item_def.inventory_image, def, item_def)
        function item_def.on_use(itemstack, player, pointed_thing)
            if not docost(player) then return end
            return f(itemstack, player, pointed_thing)
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
    cost = 2,
    hit_node = function(self, pos, last_empty_pos)
        local flammable = minetest.get_item_group(minetest.get_node(pos).name, "flammable")
        local puts_out = minetest.get_item_group(minetest.get_node(pos).name, "puts_out_fire")
        if puts_out > 0 then
            -- No chance of a fire starting here.
            return true
        end
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

if rawget(_G, 'tnt') and tnt.boom then
    local hit_node = function(self, pos, last_empty_pos)
        local puts_out = minetest.get_item_group(minetest.get_node(pos).name, "puts_out_fire")
        if puts_out > 0 then
            -- This spell can travel through water.
            return false
        end
        tnt.boom(pos, {
            radius = 3,
            damage_radius = 5,
        })
        return true
    end
    magic.register_spell("magic:spell_bomb", {
        description = "Bomb Spell",
        type = "missile",
        color = "#FA0",
        emblem = "attack",
        speed = 15,
        cost = 6,
        hit_node = hit_node,
        hit_object = function(self, pos)
            return hit_node(self, pos)
        end,
    })
    minetest.register_craft({
        output = "magic:spell_bomb",
        recipe = {
            {"magic:spell_fire", "group:minor_spellbinding", "magic:area_essence"},
        },
    })
end
