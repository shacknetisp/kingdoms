-- The fireball, ignites flames and deals fire damage.
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
    hit_object = function(self, pos, obj)
        magic.damage_obj(obj, {fire = 4})
        return true
    end,
})
minetest.register_craft({
    output = "magic:spell_fire",
    recipe = {
        {"magic:rage_essence", "group:minor_spellbinding"},
    },
})
minetest.register_craft({
    type = "fuel",
    recipe = "magic:spell_fire",
    burntime = 550,
})

-- The bomb, creates a TNT-style explosion at the contact point.
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
        gravity = 0.5,
        hit_node = hit_node,
        hit_object = function(self, pos, obj)
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

-- A weak but cheap dart.
magic.register_spell("magic:spell_dart", {
    description = "Dart Spell",
    type = "missile",
    color = "#333",
    emblem = "attack",
    speed = 60,
    cost = 1,
    hit_object = function(self, pos, obj)
        magic.damage_obj(obj, {fleshy = 2})
        return true
    end,
})
minetest.register_craft({
    output = "magic:spell_dart 6",
    recipe = {
        {"magic:area_essence", "magic:solidity_essence"},
        {"group:minor_spellbinding", "group:stone"},
    },
})

-- A weak dart that deals armor-bypassing magic and fire damage.
magic.register_spell("magic:spell_missile", {
    description = "Missile Spell",
    type = "missile",
    color = "#04F",
    emblem = "attack",
    speed = 50,
    cost = 1,
    hit_object = function(self, pos, obj)
        magic.damage_obj(obj, {magic = 1, fire = 1})
        return true
    end,
})
minetest.register_craft({
    output = "magic:spell_missile 2",
    recipe = {
        {"magic:rage_essence", "magic:day_essence", "group:minor_spellbinding"},
    },
})
