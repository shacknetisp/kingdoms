-- Create a small explosion of flowing water.
local function drop_water(self, pos)
    local water = "default:water_flowing"
    local limit = 5
    -- Put out fires first.
    local positions = kingdoms.utils.shuffled(kingdoms.utils.find_nodes_by_area(pos, 3, {"fire:basic_flame"}))
    for _,p in ipairs(positions) do
        limit = limit - 1
        minetest.set_node(p, {name=water})
        if limit <= 0 then
            break
        end
    end
    limit = math.max(limit, 3)
    -- A smaller air radius, avoiding travel through thick walls.
    positions = kingdoms.utils.shuffled(kingdoms.utils.find_nodes_by_area(pos, 1, {"air"}))
    for _,p in ipairs(positions) do
        limit = limit - 1
        minetest.set_node(p, {name=water})
        if limit <= 0 then
            break
        end
    end
    return true
end

magic.register_spell("magic:spell_water", {
    description = "Water Spell",
    type = "missile",
    color = "#00F",
    emblem = "action",
    speed = 20,
    cost = 4,
    gravity = 0.25,
    hit_node = drop_water,
    hit_object = drop_water,
})
minetest.register_craft({
    output = "magic:spell_water 2",
    recipe = {
        {"magic:calm_essence", "group:minor_spellbinding", "magic:area_essence"},
    },
})

local function drop_ice(self, pos)
    self.firsthit = self.firsthit or pos
    if minetest.get_node(pos).name ~= "default:water_source" and minetest.get_node(pos).name ~= "default:water_flowing" then
        return true
    else
        if vector.distance(self.firsthit, pos) >= 16 then
            return true
        end
    end
    local limit = 6
    local positions = kingdoms.utils.shuffled(kingdoms.utils.find_nodes_by_area_under_air(pos, 4, {"default:water_source"}))
    for _,p in ipairs(positions) do
        limit = limit - 1
        minetest.set_node(p, {name="default:ice"})
        if limit <= 0 then
            break
        end
    end
end

-- Convert water sources to ice.
magic.register_spell("magic:spell_ice", {
    description = "Ice Spell",
    type = "missile",
    color = "#08B",
    emblem = "action",
    speed = 20,
    cost = 8,
    hit_node = drop_ice,
    hit_object = function(self, pos, obj)
        magic.damage_obj(obj, {cold = 4})
        return true
    end,
})
minetest.register_craft({
    output = "magic:spell_ice 2",
    recipe = {
        {"magic:concentrated_night_essence", "magic:calm_essence", ""},
        {"group:minor_spellbinding", "magic:area_essence", "magic:solidity_essence"},
    },
})
